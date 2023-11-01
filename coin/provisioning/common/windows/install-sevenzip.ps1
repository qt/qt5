# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script installs 7-Zip

$version = "23.01"
$nonDottedVersion = "2301"

$cpu_arch = Get-CpuArchitecture
switch ($cpu_arch) {
    arm64 {
        $arch = "-arm64"
        $sha1 = "be65c2ea6119c04945c66b13413892f2bb03d9a7"
        Break
    }
    x64 {
        $arch = "-x64"
        $sha1 = "7DF28D340D7084647921CC25A8C2068BB192BDBB"
        Break
    }
    x86 {
        $arch = ""
        $sha1 = "D5D00E6EA8B8E68CE7A704FD478DC950E543C25C"
        Break
    }
    default {
        throw "Unknown architecture $cpu_arch"
    }
}

$url_cache = "https://ci-files01-hki.ci.qt.io/input/windows/7z" + $nonDottedVersion + $arch + ".exe"
$url_official = "http://www.7-zip.org/a/7z" + $nonDottedVersion + $arch + ".exe"
$7zPackage = "C:\Windows\Temp\7zip-$nonDottedVersion.exe"
$7zTargetLocation = "C:\Utils\sevenzip\"

Download $url_official $url_cache $7zPackage
Verify-Checksum $7zPackage $sha1
Run-Executable $7zPackage "/S","/D=$7zTargetLocation"

Write-Host "Cleaning $7zPackage.."
Remove "$7zPackage"

Add-Path $7zTargetLocation

Write-Output "7-Zip = $version" >> ~\versions.txt
