# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install Notepad++

$version = "8.6.5"

$cpu_arch = Get-CpuArchitecture
switch ($cpu_arch) {
    arm64 {
        $arch = ".arm64"
        $sha1 = "eecb8a6b6ed3cb1e467d227b8b7751283c35434e"
        Break
    }
    x64 {
        $arch = ".x64"
        $sha1 = "a0bf3fb15015bc1fbcb819d9a9c61f4762f4a10f"
        Break
    }
    x86 {
        $arch = ""
        $sha1 = "ba940c6b526da1ce127f43b835b4d8c9d5c4b59c"
        Break
    }
    default {
        throw "Unknown architecture $cpu_arch"
    }
}

$filename_exe = "npp." + $version + ".Installer" + $arch + ".exe"
$url_cache = "https://ci-files01-hki.ci.qt.io/input/windows/" + $filename_exe
$url_official = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v" + $version + "/" + $filename_exe
$nppPackage = "C:\Windows\Temp\npp-$version.exe"

Download $url_official $url_cache $nppPackage
Verify-Checksum $nppPackage $sha1
Run-Executable "$nppPackage" "/S"

Write-Host "Cleaning $nppPackage.."
Remove "$nppPackage"

Write-Output "Notepad++ = $version" >> ~\versions.txt

Write-Host "Disabling auto updates."
Rename-Item -Path "C:\Program Files\Notepad++\updater" -NewName "updater_disabled"
