# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install Java SE
# https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html
$version_major = "17"

$cpu_arch = Get-CpuArchitecture
switch ($cpu_arch) {
    arm64 {
        $version = "17.0.11"
        $arch = "aarch64"
        $sha1 = "1c5984a185778ad91498b746e677d84e153d5918"
        # Using Microsoft build version of OpenJDK from: https://learn.microsoft.com/en-us/java/openjdk/download
        # as there are no available Windows ARM64 versions of JDK from Oracle
        $url_official = "https://aka.ms/download-jdk/microsoft-jdk-${version}-windows-${arch}.msi"
        $url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\microsoft-jdk-${version}-windows-${arch}.msi"
        $javaPackage = "C:\Windows\Temp\jdk-$version.msi"
        # Microsoft installer does not allow to override the installation path using the regular
        # TARGETDIR or INSTALLDIR properties, so just hardcode the path that it uses
        $installdir = "C:\Program Files\Microsoft\jdk-17.0.11.9-hotspot"
        Break
    }
    x64 {
        $version = "17.0.10"
        $arch = "x64"
        $sha1 = "d573091930076c3ffa9f74273cb41cb5c75c5400"
        $url_official = "https://download.oracle.com/java/17/archive/jdk-${version}_windows-${arch}_bin.exe"
        $url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\jdk-$version-windows-$arch.exe"
        $javaPackage = "C:\Windows\Temp\jdk-$version.exe"
        $installdir = "C:\Program Files\Java\jdk-$version_major"
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

Set-EnvironmentVariable "JAVA_HOME" "$installdir"
Prepend-Path "$installdir\bin"

Write-Output "Java SE = $version $arch" >> ~\versions.txt
