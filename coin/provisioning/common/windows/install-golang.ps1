# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

$version = "1.22.4"

$cpu_arch = Get-CpuArchitecture
switch ($cpu_arch) {
    x64 {
        $arch = "amd64"
        $sha256 = "3c21105d7b584759b6e266383b777caf6e87142d304a10b539dbc66ab482bb5f"
        break
    }
    x86 {
        $arch = "386"
        $sha256 = "5c6446e2ea80bc6a971d2b34446f16e6517e638b0ff8d3ea229228d1931790b0"
        break
    }
    arm64 {
        $arch = "arm64"
        $sha256 = "553cc6c460f4e3eb4fad5b897c0bb22cd8bbeb20929f0e3eeb939420320292ce"
        break
    }
    default {
        throw "Unknown architecture $cpu_arch"
    }
}

$goPackage = "C:\Windows\Temp\Go-" + $version + $arch + ".msi"
$url_cache = "https://ci-files01-hki.ci.qt.io/input/go/windows/go" + $version + ".windows-" + $arch + ".msi"
$url_official = "https://go.dev/dl/go" + $version + ".windows-" + $arch + ".msi"

Write-Host "Fetching Go $version..."
Download $url_official $url_cache $goPackage
Verify-Checksum $goPackage $sha256 sha256
Write-Host "Installing Go $version..."
Run-Executable "msiexec" "/quiet /i $goPackage"
Write-Output "Go = $version" >> ~\versions.txt
