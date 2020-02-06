############################################################################
##
## Copyright (C) 2018 The Qt Company Ltd.
## Contact: http://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL21$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see http://www.qt.io/terms-conditions. For further
## information use the contact form at http://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 2.1 or version 3 as published by the Free
## Software Foundation and appearing in the file LICENSE.LGPLv21 and
## LICENSE.LGPLv3 included in the packaging of this file. Please review the
## following information to ensure the GNU Lesser General Public License
## requirements will be met: https://www.gnu.org/licenses/lgpl.html and
## http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
##
## As a special exception, The Qt Company gives you certain additional
## rights. These rights are described in The Qt Company LGPL Exception
## version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
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
$ndkVersion = "r20"
$ndkCachedUrl = "\\ci-files01-hki.intra.qt.io\provisioning\android\android-ndk-$ndkVersion-windows-x86_64.zip"
$ndkOfficialUrl = "https://dl.google.com/android/repository/android-ndk-$ndkVersion-windows-x86_64.zip"
$ndkChecksum = "36e1dc77fad08ad2498fb94b13ad8caf26bbd9df"
$ndkFolder = "c:\Utils\Android\android-ndk-$ndkVersion"
$ndkZip = "c:\Windows\Temp\android_ndk_$ndkVersion.zip"

# SDK
$toolsVersion = "26.1.1"
$toolsFile = "sdk-tools-windows-4333796.zip"
$sdkApi = "ANDROID_API_VERSION"
$sdkApiLevel = "android-28"
$sdkBuildToolsVersion = "28.0.3"
$toolsCachedUrl= "\\ci-files01-hki.intra.qt.io\provisioning\android\$toolsFile"
$toolsOfficialUrl = "https://dl.google.com/android/repository/$toolsFile"
$toolsChecksum = "aa298b5346ee0d63940d13609fe6bec621384510"
$toolsFolder = "c:\Utils\Android\tools"
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
Set-EnvironmentVariable "ANDROID_NDK_HOME" $ndkFolder
Set-EnvironmentVariable "ANDROID_NDK_ROOT" $ndkFolder

Install $toolsCachedUrl $sdkZip $toolsChecksum $sdkOfficialUrl
Set-EnvironmentVariable "ANDROID_SDK_HOME" C:\Utils\Android
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

cd $toolsFolder\bin\
$sdkmanager_args += "platforms;$sdkApiLevel", "platform-tools", "build-tools;$sdkBuildToolsVersion"
$command = 'for($i=0;$i -lt 6;$i++) { $response += "y`n"}; $response | .\sdkmanager.bat @sdkmanager_args | Out-Null'
Invoke-Expression $command
$command = 'for($i=0;$i -lt 6;$i++) { $response += "y`n"}; $response | .\sdkmanager.bat --licenses'
iex $command
cmd /c "dir C:\Utils\android"

Write-Output "Android SDK tools= $toolsVersion" >> ~/versions.txt
Write-Output "Android SDK Build Tools = $sdkBuildToolsVersion" >> ~/versions.txt
Write-Output "Android SDK Api Level = $sdkApiLevel" >> ~/versions.txt
Write-Output "Android NDK = $ndkVersion" >> ~/versions.txt
