# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

$majorminorversion = "4.3"
$version = "4.3.2"

$cpu_arch = Get-CpuArchitecture
Write-Host "Installing CMake for architecture $cpu_arch"
switch ($cpu_arch) {
    arm64 {
        $arch = "arm64"
        $sha1 = "71949e4637accf5a92f35d357dc861e6a8d645cf"
        $majorminorversion = "4.3"
        $version = "4.3.2"
        Break
    }
    x64 {
        $arch = "i386"
        $sha1 = "abc3ae51ec5a11fb367a39ddfb7db0c9ea697a7b"
    }
    default {
        throw "Unknown architecture $cpu_arch"
    }
}

$filename = "cmake-" + $version + "-windows-" + $arch
$filename_zip = $filename + ".zip"

$zip = Get-DownloadLocation ($filename_zip)
$officialurl = "https://cmake.org/files/v" + $majorminorversion + "/" + $filename_zip
$cachedurl = "https://ci-files01-hki.ci.qt.io/input/cmake/" + $filename_zip

Write-Host "Removing old cmake"
Remove "C:\CMake"

Download $officialurl $cachedurl $zip
Verify-Checksum $zip $sha1

Extract-7Zip $zip C:
$defaultinstallfolder = "C:\" + $filename
Rename-Item $defaultinstallfolder C:\CMake

Add-Path "C:\CMake\bin"

Write-Output "CMake = $version" >> ~\versions.txt

