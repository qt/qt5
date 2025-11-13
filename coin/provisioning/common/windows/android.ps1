# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script installs Android sdk and ndk
# It also runs update for SDK API level 21, latest SDK tools, latest platform-tools and build-tools version $sdkBuildToolsVersion
# Android 16 is the minimum requirement for Qt 5.7 applications, but we need something more recent than that for building Qt itself.
# E.g The Bluetooth features that require Android 21 will disable themselves dynamically when running on an Android 16 device.
# That's why we need to use Andoid-21 API version in Qt 5.9.

# NDK
$ndkZip = "C:\Windows\Temp\android_ndk.zip"

$ndkVersionLatest = "r27c"
$ndkChecksumLatest = "ac5f7762764b1f15341094e148ad4f847d050c38"
$ndkCachedUrlLatest = "\\ci-files01-hki.ci.qt.io\provisioning\android\android-ndk-$ndkVersionLatest-windows.zip"
$ndkOfficialUrlLatest = "https://dl.google.com/android/repository/android-ndk-$ndkVersionLatest-windows.zip"

# NDK in alpha/beta/RC state

$ndkVersionPreview = "r29-beta2"
$ndkChecksumPreview = "59b665f7506f1079771393f2c90f3cb29817ecfb"
$ndkCachedUrlPreview = "\\ci-files01-hki.ci.qt.io\provisioning\android\android-ndk-$ndkVersionPreview-windows.zip"
$ndkOfficialUrlPreview = "https://dl.google.com/android/repository/android-ndk-$ndkVersionPreview-windows.zip"

# Non-latest (but still supported by the qt/qt5 branch) NDKs are installed for nightly targets in:
# coin/platform_configs/nightly_android.yaml

$ndkVersionNightly1 = $ndkVersionLatest  # Same version = skip NDK install for nightly
$ndkChecksumNightly1 = $ndkChecksumLatest
$ndkCachedUrlNightly1 = "\\ci-files01-hki.ci.qt.io\provisioning\android\android-ndk-$ndkVersionNightly1-windows.zip"
$ndkOfficialUrlNightly1 = "https://dl.google.com/android/repository/android-ndk-$ndkVersionNightly1-windows.zip"

$ndkVersionNightly2 = $ndkVersionLatest
$ndkChecksumNightly2 = $ndkChecksumLatest
$ndkCachedUrlNightly2 = "\\ci-files01-hki.ci.qt.io\provisioning\android\android-ndk-$ndkVersionNightly2-windows.zip"
$ndkOfficialUrlNightly2 = "https://dl.google.com/android/repository/android-ndk-$ndkVersionNightly2-windows.zip"

# SDK
$toolsVersion = "19.0"
$toolsFile = "commandlinetools-win-13114758_latest.zip"
$sdkApi = "ANDROID_API_VERSION"
$sdkApiLevel = "android-35"
$sdkBuildToolsVersion = "35.0.1"
$toolsCachedUrl= "\\ci-files01-hki.ci.qt.io\provisioning\android\$toolsFile"
$toolsOfficialUrl = "https://dl.google.com/android/repository/$toolsFile"
$toolsChecksum = "54a582f3bf73e04253602f2d1c80bd5868aac115"
$cmdFolder = "c:\Utils\Android\cmdline-tools"

$sdkZip = "c:\Windows\Temp\$toolsFile"
New-Item -ItemType Directory -Path C:\Utils\Android\
New-Item -ItemType Directory -Path C:\Windows\Temp\android_extract

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

Write-Host "Installing Android NDK $nkdVersionLatest"
$ndkFolderLatest = Install $ndkCachedUrlLatest $ndkZip $ndkChecksumLatest $ndkOfficialUrlLatest
Set-EnvironmentVariable "ANDROID_NDK_ROOT_LATEST" $ndkFolderLatest
# To be used by vcpkg
Set-EnvironmentVariable "ANDROID_NDK_HOME" $ndkFolderLatest

if ($ndkVersionPreview -ne $ndkVersionLatest) {
    Write-Host "Installing Android NDK $ndkVersionPreview"
    $ndkFolderPreview = Install $ndkCachedUrlPreview $ndkZip $ndkChecksumPreview $ndkOfficialUrlPreview
    Set-EnvironmentVariable "ANDROID_NDK_ROOT_PREVIEW" $ndkFolderPreview
    Write-Output "Android NDK = $ndkVersionPreview" >> ~/versions.txt
}

if ($ndkVersionNightly1 -ne $ndkVersionLatest) {
    Write-Host "Installing Android NDK $ndkVersionNightly1"
    $ndkFolderNightly = Install $ndkCachedUrlNightly1 $ndkZip $ndkChecksumNightly1 $ndkOfficialUrlNightly1
    Set-EnvironmentVariable "ANDROID_NDK_ROOT_NIGHTLY1" $ndkFolderNightly
    Write-Output "Android NDK = $ndkVersionNightly1" >> ~/versions.txt
}

if ($ndkVersionNightly2 -ne $ndkVersionLatest) {
    Write-Host "Installing Android NDK $ndkVersionNightly2"
    $ndkFolderNightly = Install $ndkCachedUrlNightly2 $ndkZip $ndkChecksumNightly2 $ndkOfficialUrlNightly2
    Set-EnvironmentVariable "ANDROID_NDK_ROOT_NIGHTLY2" $ndkFolderNightly
    Write-Output "Android NDK = $ndkVersionNightly2" >> ~/versions.txt
}

# Android Command-Line Tools unpacks a directory 'cmdline-tools'. Due
# to existing code, weed to move it into 'cmdline-tools/tools'
Write-Host "Downloading Android Command-Line Tools"
$toolsFolder = Install $toolsCachedUrl $sdkZip $toolsChecksum $toolsOfficialUrl
Rename-Item -Path "$toolsFolder" -NewName "c:\Utils\Android\tools"
New-Item -ItemType directory -Path $cmdFolder
Move-Item -Path "c:\Utils\Android\tools" -Destination "$cmdFolder\tools"
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
Write-Output "Android NDK = $ndkVersionLatest" >> ~/versions.txt
