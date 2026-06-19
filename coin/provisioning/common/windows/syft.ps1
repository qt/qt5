# Copyright (C) 2026 The Qt Company Ltd
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

$version = "1.45.1"

$cpu_arch = Get-CpuArchitecture
Write-Host "Installing Syft for architecture $cpu_arch"
switch ($cpu_arch) {
    arm64 {
        $arch = "arm64"
        $sha1 = "f629f6fa9c542e8803aa13987f8104a441c15878"
        Break
    }
    x64 {
        $arch = "amd64"
        $sha1 = "debd2e1e77763fe8cf224e791abf79e11dc4a93b"
        Break
    }
    default {
        throw "Unknown architecture $cpu_arch"
    }
}

$filename = "syft_" + $version + "_windows_" + $arch
$filename_zip = $filename + ".zip"

$zip = Get-DownloadLocation ($filename_zip)
$externalUrl = "https://github.com/anchore/syft/releases/download/v" + $version + "/" + $filename_zip
$internalUrl = "https://ci-files01-hki.ci.qt.io/input/syft/" + $filename_zip

Write-Host "Removing old syft"
Remove "C:\syft"

Download $externalUrl $internalUrl $zip
Verify-Checksum $zip $sha1

Extract-7Zip $zip C:\syft
Remove "$zip"

Add-Path "C:\syft"

Write-Output "Syft ($arch) = $version" >> ~\versions.txt
