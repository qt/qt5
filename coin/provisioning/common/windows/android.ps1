# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script installs Android sdk and ndk
# It also runs update for SDK API level 21, latest SDK tools, latest platform-tools and build-tools version $sdkBuildToolsVersion
# Android 16 is the minimum requirement for Qt 5.7 applications, but we need something more recent than that for building Qt itself.
# E.g The Bluetooth features that require Android 21 will disable themselves dynamically when running on an Android 16 device.
# That's why we need to use Andoid-21 API version in Qt 5.9.

# NDK
$ndkVersionLatest = "r26b"
$ndkVersionDefault = $ndkVersionLatest
$ndkChecksumLatest = "17453c61a59e848cffb8634f2c7b322417f1732e"
$ndkChecksumDefault = $ndkChecksumLatest
$ndkCachedUrlLatest = "\\ci-files01-hki.ci.qt.io\provisioning\android\android-ndk-$ndkVersionLatest-windows.zip"
$ndkOfficialUrlLatest = "https://dl.google.com/android/repository/android-ndk-$ndkVersionLatest-windows.zip"
$ndkCachedUrlDefault = "\\ci-files01-hki.ci.qt.io\provisioning\android\android-ndk-$ndkVersionDefault-windows.zip"
$ndkOfficialUrlDefault = "https://dl.google.com/android/repository/android-ndk-$ndkVersionDefault-windows.zip"
$ndkZip = "C:\Windows\Temp\android_ndk.zip"

# SDK
$toolsVersion = "2.1"
$toolsFile = "commandlinetools-win-6609375_latest.zip"
$sdkApi = "ANDROID_API_VERSION"
$sdkApiLevel = "android-34"
$sdkBuildToolsVersion = "34.0.0"
$toolsCachedUrl= "\\ci-files01-hki.ci.qt.io\provisioning\android\$toolsFile"
$toolsOfficialUrl = "https://dl.google.com/android/repository/$toolsFile"
$toolsChecksum = "e2e19c2ff584efa87ef0cfdd1987f92881323208"
$cmdFolder = "c:\Utils\Android\cmdline-tools"

$sdkZip = "c:\Windows\Temp\$toolsFile"

function Install($1, $2, $3, $4) {
    $cacheUrl = $1
    $zip = $2
    $checksum = $3
    $offcialUrl = $4
    $tempExtractDir = "C:\Windows\Temp\android_extract"

    Download $offcialUrl $cacheUrl $zip
    Verify-Checksum $zip "$checksum"
    Extract-7Zip $zip $tempExtractDir
    $baseDirectory = (Get-ChildItem $tempExtractDir -Attributes D | Select-Object -First 1).Name
    Move-Item -Path ($tempExtractDir + "\" + $baseDirectory) -Destination "C:\Utils\Android\$baseDirectory" -Force
    Remove $zip

    return "C:\Utils\Android\$baseDirectory"
}

New-Item -ItemType Directory -Path C:\Utils\Android\
New-Item -ItemType Directory -Path C:\Windows\Temp\android_extract
Write-Host "Installing Android NDK $ndkVersionDefault"
$ndkFolderDefault = Install $ndkCachedUrlDefault $ndkZip $ndkChecksumDefault $ndkOfficialUrlDefault
Set-EnvironmentVariable "ANDROID_NDK_ROOT_DEFAULT" $ndkFolderDefault
# To be used by vcpkg
Set-EnvironmentVariable "ANDROID_NDK_HOME" $ndkFolderDefault
$env:ANDROID_NDK_HOME = "$ndkFolderDefault"

if ($ndkVersionDefault -eq $ndkVersionLatest) {
    Write-Host "Android Latest version is the same than Default. NDK installation done."
} else {
    Write-Host "Installing Android NDK $nkdVersionLatest"
    $ndkFolderLatest = Install $ndkCachedUrlLatest $ndkZip $ndkChecksumLatest $ndkOfficialUrlLatest
    Set-EnvironmentVariable "ANDROID_NDK_ROOT_LATEST" $ndkFolderLatest
}

$toolsFolder = Install $toolsCachedUrl $sdkZip $toolsChecksum $toolsOfficialUrl
New-Item -ItemType directory -Path $cmdFolder
Move-Item -Path $toolsFolder -Destination $cmdFolder\
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

cd $cmdFolder\tools\bin\
$sdkmanager_args += "platforms;$sdkApiLevel", "platform-tools", "build-tools;$sdkBuildToolsVersion", "--sdk_root=C:\Utils\Android"
$command = 'for($i=0;$i -lt 6;$i++) { $response += "y`n"}; $response | .\sdkmanager.bat @sdkmanager_args | Out-Null'
Invoke-Expression $command
$command = 'for($i=0;$i -lt 6;$i++) { $response += "y`n"}; $response | .\sdkmanager.bat --licenses'
iex $command
cmd /c "dir C:\Utils\android"

Write-Output "Android SDK tools= $toolsVersion" >> ~/versions.txt
Write-Output "Android SDK Build Tools = $sdkBuildToolsVersion" >> ~/versions.txt
Write-Output "Android SDK Api Level = $sdkApiLevel" >> ~/versions.txt
Write-Output "Android NDK = $ndkVersionDefault" >> ~/versions.txt
