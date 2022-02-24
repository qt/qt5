############################################################################
##
## Copyright (C) 2022 The Qt Company Ltd.
## Contact: https://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see https://www.qt.io/terms-conditions. For further
## information use the contact form at https://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 3 as published by the Free Software
## Foundation and appearing in the file LICENSE.LGPL3 included in the
## packaging of this file. Please review the following information to
## ensure the GNU Lesser General Public License version 3 requirements
## will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 2.0 or (at your option) the GNU General
## Public license version 3 or any later version approved by the KDE Free
## Qt Foundation. The licenses are as published by the Free Software
## Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
## included in the packaging of this file. Please review the following
## information to ensure the GNU General Public License requirements will
## be met: https://www.gnu.org/licenses/gpl-2.0.html and
## https://www.gnu.org/licenses/gpl-3.0.html.
##
## $QT_END_LICENSE$
##
#############################################################################

. "$PSScriptRoot\helpers.ps1"

# This script installs Android sdk and ndk
# It also runs update for SDK API level 21, latest SDK tools, latest platform-tools and build-tools version $sdkBuildToolsVersion
# Android 16 is the minimum requirement for Qt 5.7 applications, but we need something more recent than that for building Qt itself.
# E.g The Bluetooth features that require Android 21 will disable themselves dynamically when running on an Android 16 device.
# That's why we need to use Andoid-21 API version in Qt 5.9.

# NDK
$ndkVersion = "r23b"
$ndkCachedUrl = "\\ci-files01-hki.intra.qt.io\provisioning\android\android-ndk-$ndkVersion-windows.zip"
$ndkOfficialUrl = "https://dl.google.com/android/repository/android-ndk-$ndkVersion-windows.zip"
$ndkChecksum = "6e3fb50022c611a2b13d02f5de5c21cc7206a298"
$ndkFolder = "c:\Utils\Android\android-ndk-$ndkVersion"
$ndkZip = "c:\Windows\Temp\android_ndk_$ndkVersion.zip"

# SDK
$toolsVersion = "2.1"
$toolsFile = "commandlinetools-win-6609375_latest.zip"
$sdkApi = "ANDROID_API_VERSION"
$sdkApiLevel = "android-31"
$sdkBuildToolsVersion = "31.0.0"
$toolsCachedUrl= "\\ci-files01-hki.intra.qt.io\provisioning\android\$toolsFile"
$toolsOfficialUrl = "https://dl.google.com/android/repository/$toolsFile"
$toolsChecksum = "e2e19c2ff584efa87ef0cfdd1987f92881323208"
$toolsFolder = "c:\Utils\Android\cmdline-tools"

$sdkZip = "c:\Windows\Temp\$toolsFile"

function Install($1, $2, $3, $4) {
    $cacheUrl = $1
    $zip = $2
    $checksum = $3
    $offcialUrl = $4

    Download $offcialUrl $cacheUrl $zip
    Verify-Checksum $zip "$checksum"
    Extract-7Zip $zip C:\Utils\Android
}

Write-Host "Installing Android NDK $nkdVersion"
Install $ndkCachedUrl $ndkZip $ndkChecksum $ndkOfficialUrl
Set-EnvironmentVariable "ANDROID_NDK_ROOT" $ndkFolder

Install $toolsCachedUrl $sdkZip $toolsChecksum $sdkOfficialUrl
New-Item -ItemType directory -Path $toolsFolder
Move-Item -Path C:\Utils\Android\tools -Destination $toolsFolder\
Set-EnvironmentVariable "ANDROID_SDK_ROOT" "C:\Utils\Android"
Set-EnvironmentVariable "ANDROID_API_VERSION" $sdkApiLevel

if (IsProxyEnabled) {
    $proxy = Get-Proxy
    Write-Host "Using proxy ($proxy) with sdkmanager"
    # Remove "http://" from the beginning
    $proxy = $proxy.Remove(0,7)
    $proxyhost,$proxyport = $proxy.split(':')
    $sdkmanager_args = "--no_https", "--proxy=http", "--proxy_host=`"$proxyhost`"", "--proxy_port=`"$proxyport`""
}

New-Item -ItemType Directory -Force -Path C:\Utils\Android\licenses
$licenseString = "`nd56f5187479451eabf01fb78af6dfcb131a6481e"
Out-File -FilePath C:\Utils\Android\licenses\android-sdk-license -Encoding utf8 -InputObject $licenseString

# Get a PATH where Java's path is defined from previous provisioning
[Environment]::SetEnvironmentVariable("PATH", [Environment]::GetEnvironmentVariable("PATH", "Machine"), "Process")

# Attempt to catch all errors of sdkmanager.bat, even when hidden behind a pipeline.
$ErrorActionPreference = "Stop"

cd $toolsFolder\tools\bin\
$sdkmanager_args += "platforms;$sdkApiLevel", "platform-tools", "build-tools;$sdkBuildToolsVersion", "--sdk_root=C:\Utils\Android"
$command = 'for($i=0;$i -lt 6;$i++) { $response += "y`n"}; $response | .\sdkmanager.bat @sdkmanager_args | Out-Null'
Invoke-Expression $command
$command = 'for($i=0;$i -lt 6;$i++) { $response += "y`n"}; $response | .\sdkmanager.bat --licenses'
iex $command
cmd /c "dir C:\Utils\android"

Write-Output "Android SDK tools= $toolsVersion" >> ~/versions.txt
Write-Output "Android SDK Build Tools = $sdkBuildToolsVersion" >> ~/versions.txt
Write-Output "Android SDK Api Level = $sdkApiLevel" >> ~/versions.txt
Write-Output "Android NDK = $ndkVersion" >> ~/versions.txt
