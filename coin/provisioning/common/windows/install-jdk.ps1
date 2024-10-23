# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install Java SE
# https://www.oracle.com/java/technologies/javase/jdk21-archive-downloads.html
$version_major = "21"

$cpu_arch = Get-CpuArchitecture
switch ($cpu_arch) {
    arm64 {
        $version = "21.0.9"
        $arch = "aarch64"
        $sha1 = "293cca7b76e3280573061f53dbe41ced527e3b4d"
        # Using Microsoft build https://aka.ms/download-jdk/ - no .msi available
        $url_official = "https://aka.ms/download-jdk/microsoft-jdk-${version}-windows-${arch}.exe"
        $url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\microsoft-jdk-${version}-windows-${arch}.exe"
        $javaPackage = "C:\Windows\Temp\jdk-$version.exe"
        # Microsoft installer does not allow to override the installation path using the regular
        # TARGETDIR or INSTALLDIR properties, so just hardcode the path that it uses
        $installdir = "C:\Program Files\Microsoft\jdk-$version-hotspot"
        Break
    }
    x64 {
        $version = "21.0.9"
        $arch = "x64"
        $sha1 = "b4b10fd43993650053c41f377af37b37a2267b74"
        # Downloading from https://aka.ms/download-jdk/microsoft-jdk-21.0.9-windows-x64.exe
        $url_official = "https://aka.ms/download-jdk/microsoft-jdk-${version}_windows-${arch}.exe"
        $url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\microsoft-jdk-$version-windows-$arch.exe"
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
    Run-Executable "$javaPackage" "/SILENT /SUPPRESSMSGBOXES /ALLUSERS /DIR=`"$installdir`""
} else {
    Run-Executable "msiexec" "/quiet /i $javaPackage"
}
Remove "$javaPackage"

Set-EnvironmentVariable "JAVA_HOME" "$installdir"
Prepend-Path "$installdir\bin"

Write-Output "Java SE = $version $arch" >> ~\versions.txt
