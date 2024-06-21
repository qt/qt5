# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
. "$PSScriptRoot\helpers.ps1"

# Install Git

$version = "1.22.4"
if (Is64BitWinHost) {
    $arch = "amd64"
    $sha256 = "3c21105d7b584759b6e266383b777caf6e87142d304a10b539dbc66ab482bb5f"
} else {
    $arch = "386"
    $sha256 = "5c6446e2ea80bc6a971d2b34446f16e6517e638b0ff8d3ea229228d1931790b0"
}
$goPackage = "C:\Windows\Temp\Go-" + $version + $arch + ".msi"
$url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\Go-" + $version + $arch + ".exe"
$url_official = "https://go.dev/dl/go" + $version + ".windows-" + $arch + ".msi"

Write-Host "Fetching Go $version..."
Download $url_official $url_cache $goPackage
Verify-Checksum $goPackage $sha256 sha256
Write-Host "Installing Go $version..."
Run-Executable "msiexec" "/quiet /i $goPackage"
Write-Output "Go = $version" >> ~\versions.txt
