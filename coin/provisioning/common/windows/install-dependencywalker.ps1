# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install Dependency Walker 2.2.6000

$version = "2.2.6000"
$cpu_arch = Get-CpuArchitecture
switch ($cpu_arch) {
    x64 {
        $arch = "_x64"
        $sha1 = "4831D2A8376D64110FF9CD18799FE6C69509D3EA"
        $nuitka_arch = "x86_64"
    }
    arm64 {
        # There is no ARM64 version of Dependency Walker
        # just use the x64 version
        $arch = "_x64"
        $sha1 = "4831D2A8376D64110FF9CD18799FE6C69509D3EA"
        $nuitka_arch = "arm64"
    }
    x86 {
        $arch = "_x86"
        $sha1 = "bfec714057e8449b0246051be99ba46a7760bab9"
        $nuitka_arch = "x86"
    }
    default {
        throw "Unknown architecture $cpu_arch"
    }
}
$url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\depends22" + $arch + ".zip"
$url_official = "http://www.dependencywalker.com/depends22" + $arch + ".zip"
$dependsPackage = "C:\Windows\Temp\depends-$version.zip"

$TARGETDIR = "C:\Utils\dependencywalker"
if (!(Test-Path -Path $TARGETDIR )) {
    New-Item -ItemType directory -Path $TARGETDIR
}
Download $url_official $url_cache $dependsPackage
Verify-Checksum $dependsPackage $sha1

Extract-7Zip $dependsPackage $TARGETDIR

# Copy the content also into the cache location of nuitka
# This makes it usable without the need to download it again
Copy-Item -Path $TARGETDIR -Destination "$env:LOCALAPPDATA\Nuitka\Nuitka\Cache\downloads\depends\$nuitka_arch" -Recurse

Write-Host "Cleaning $dependsPackage.."
Remove "$dependsPackage"

Write-Output "Dependency Walker = $version" >> ~\versions.txt
