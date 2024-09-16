# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

$majorminorversion = "4.2"
$version = "4.2.4"

$cpu_arch = Get-CpuArchitecture
Write-Host "Installing UPX for architecture $cpu_arch"
switch ($cpu_arch) {
    x64 {
        $arch = "win64"
        $sha1 = "204ae110a84d0046b242222f97b19cf3f5594f4b"
    }
    default {
        throw "Unknown architecture $cpu_arch"
    }
}

$filename = "upx-" + $version + "-" + $arch
$filename_zip = $filename + ".zip"

$zip = Get-DownloadLocation ($filename_zip)
$officialurl = "https://github.com/upx/upx/releases/download/v" + $version + "/" + $filename_zip
$cachedurl = "https://ci-files01-hki.ci.qt.io/input/upx/windows/" + $filename_zip

Write-Host "Removing old UPX"
Remove "C:\UPX"

Download $officialurl $cachedurl $zip
Verify-Checksum $zip $sha1

Extract-7Zip $zip C:
$defaultinstallfolder = "C:\" + $filename
Rename-Item $defaultinstallfolder C:\UPX

Add-Path "C:\UPX"

Write-Output "UPX = $version" >> ~\versions.txt

