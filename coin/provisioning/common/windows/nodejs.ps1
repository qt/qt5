# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install Node.js
# Needed by QtWebengine

$version = "18.16.0"
if (Is64BitWinHost) {
    $arch = "x64"
    $sha256 = "007848640ba414f32d968d303e75d9841ecd2cd95d6fdd81f80bc3dcbd74ae44"
} else {
    $arch = "x86"
    $sha256 = "681be28e0acd057b4798f357d21eec5f49e21bc803bbbefeb1072bb4f166025a"
}

$package = "C:\Windows\temp\nodejs-$version.7z"
$targetFolder = "C:\Utils"
$installFolder = "C:\Utils\node-v$version-win-$arch"
$externalUrl = "https://nodejs.org/dist/v$version/node-v$version-win-$arch.7z"
$internalUrl = "http://ci-files01-hki.ci.qt.io/input/windows/node-v$version-win-$arch.7z"

Write-Host "Installing Node.js"
Download $externalUrl $internalUrl $package
Verify-Checksum $package $sha256 "sha256"
Extract-7Zip $package $targetFolder
Add-Path $installFolder
Remove $package

Write-Output "Node.js = $version" >> ~/versions.txt
