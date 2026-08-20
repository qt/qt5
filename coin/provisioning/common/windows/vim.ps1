# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

$version = "9.2.0984"
$versioned_dir = "vim92"

$cpu_arch = Get-CpuArchitecture
Write-Host "Installing vim for architecture $cpu_arch"
switch ($cpu_arch) {
    arm64 {
        $arch = "arm64"
        $sha1 = "7df12598d95edfc283015e19c430ecf6d75d28a3"
        Break
    }
    x64 {
        $arch = "x64"
        $sha1 = "decbdd2b7ad7afb18576fee51ac027f4a9610710"
    }
    default {
        throw "Unknown architecture $cpu_arch"
    }
}

$filename = "gvim_" + $version + "_" + $arch + "_signed.zip"

$officialurl = "https://github.com/vim/vim-win32-installer/releases/download/v$version/$filename"
$cachedurl = "https://ci-files01-hki.ci.qt.io/input/windows/vim/$filename"

Download $officialurl $cachedurl $filename
Verify-Checksum $filename $sha1
Extract-7Zip $filename C:\Utils

$vim_dir = "C:\Utils\vim\$versioned_dir\"
Prepend-Path $vim_dir

if (-not (Test-Path "$vim_dir\vim.exe")) {
    throw "vim.exe not found"
}
