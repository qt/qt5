# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install Java SE
# https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html
$version = "17.0.10"
$version_major = "17"

$cpu_arch = Get-CpuArchitecture
switch ($cpu_arch) {
    x64 {
        $arch = "x64"
        $sha1 = "d573091930076c3ffa9f74273cb41cb5c75c5400"
        $installdir = "C:\Program Files\Java\jdk-$version_major"
        $url_official = "https://download.oracle.com/java/17/archive/jdk-${version}_windows-${arch}_bin.exe"
        $url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\jdk-$version-windows-$arch.exe"
        $javaPackage = "C:\Windows\Temp\jdk-$version.exe"
        Break
    }
    default {
        throw "Unknown architecture $cpu_arch"
    }
}

Write-Host "Fetching Java SE $version"
$ProgressPreference = 'SilentlyContinue'
Download $url_official $url_cache $javaPackage
Verify-Checksum $javaPackage $sha1

if ($javaPackage.EndsWith(".exe")) {
    Run-Executable "$javaPackage" "/s SPONSORS=0"
} else {
    Run-Executable "msiexec" "/quiet /i $javaPackage"
}
Remove "$javaPackage"

Write-Host "Remove Java update from startup"
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" /v SunJavaUpdateSched /f

Set-EnvironmentVariable "JAVA_HOME" "$installdir"
Prepend-Path "$installdir\bin"

Write-Output "Java SE = $version $arch" >> ~\versions.txt
