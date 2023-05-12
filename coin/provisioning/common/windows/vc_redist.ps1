# Copyright (C) 2017 The Qt Company Ltd.
# Copyright (C) 2017 Pelagicore AG
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script installs Visual C++ Redistributable for Visual Studio 2015
# This is a dependency of the current python3 version

if (Is64BitWinHost) {
    Write-Host "Running in 64 bit system"
    $arch = "x64"
    $externalUrl = "https://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vc_redist.x64.exe"
    $internalUrl = "http://ci-files01-hki.ci.qt.io/input/windows/vc_redist.x64.exe"
    $sha1 = "3155cb0f146b927fcc30647c1a904cd162548c8c"
} else {
    $arch = "x86"
    $externalUrl = "https://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vc_redist.x86.exe"
    $internalUrl = "http://ci-files01-hki.ci.qt.io/input/windows/vc_redist.x86.exe"
    $sha1 = "bfb74e498c44d3a103ca3aa2831763fb417134d1"
}

$package = "C:\Windows\temp\vc_redist.$arch.exe"

Write-Host "Fetching from URL..."
Download $externalUrl $internalUrl $package
Verify-Checksum $package $sha1
Write-Host "Installing $package..."
Run-Executable $package "/q"
Remove $package
