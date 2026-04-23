# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

$version = "1.26.2"

$cpu_arch = Get-CpuArchitecture
switch ($cpu_arch) {
    x64 {
        $arch = "amd64"
        $sha256 = "84826eca833548bb2beabe7429052eaaec18faa902fde723898d906b42e59a73"
        break
    }
    x86 {
        $arch = "386"
        $sha256 = "9a63074567b8a0a94091e8f6c2096f5d4d0369c7bbaed08158a63004d8b8cac1"
        break
    }
    arm64 {
        $arch = "arm64"
        $sha256 = "f59e0e51370cac7ab5742c4ed9fc151f0a20918396c893996125a1c6ed7d9525"
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
Verify-Checksum $goPackage $sha256
Write-Host "Installing Go $version..."
Run-Executable "msiexec" "/quiet /i $goPackage"
Write-Output "Go = $version" >> ~\versions.txt
