# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install Java SE

if (Is64BitWinHost) {
    $version = "11.0.12"
    $arch = "x64"
    $sha1 = "135ffd1c350509729551876232a5354070732e92"
} else {
    $version = "8u144"
    $arch = "i586"
    $sha1 = "3b9ab95914514eaefd72b815c5d9dd84c8e216fc"
}

$installdir = "C:\Program Files\Java\jdk-$version"

$url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\jdk-" + $version + "-windows-" + $arch + ".exe"
# NOTE! Official URL is behind login portal. It can't be used whit this script instead it need to be fetched to $url_cache first
# java 11: https://www.oracle.com/java/technologies/downloads/#java11-windows
# java 8: $official_url = "http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jdk-" + $version + "-windows-" + $arch + ".exe"
$javaPackage = "C:\Windows\Temp\jdk-$version.exe"

Write-Host "Fetching Java SE $version..."
$ProgressPreference = 'SilentlyContinue'
Write-Host "...from local cache"
Download $url_cache $url_cache $javaPackage
Verify-Checksum $javaPackage $sha1

Run-Executable "$javaPackage" "/s SPONSORS=0"
Remove "$javaPackage"

Write-Host "Remove Java update from startup"
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" /v SunJavaUpdateSched /f

Set-EnvironmentVariable "JAVA_HOME" "$installdir"
Add-Path "$installdir\bin"

Write-Output "Java SE = $version $arch" >> ~\versions.txt
