# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install Node.js
# Needed by QtWebengine

$version = "12.18.0"
if (Is64BitWinHost) {
    $arch = "x64"
    $sha1 = "457b1527d249ee471a9445953a906cb10c75378d"
} else {
    $arch = "x86"
    $sha1 = "58801900f5bddca9c00feed6b84fed729426fc92"
}

$package = "C:\Windows\temp\nodejs-$version.zip"
$targetFolder = "C:\Utils"
$installFolder = "C:\Utils\node-v$version-win-$arch"
$externalUrl = "https://nodejs.org/dist/v$version/node-v$version-win-$arch.zip"
$internalUrl = "http://ci-files01-hki.intra.qt.io/input/windows/node-v$version-win-$arch.zip"

Write-Host "Installing Node.js"
Download $externalUrl $internalUrl $package
Verify-Checksum $package $sha1
Extract-7Zip $package $targetFolder
Add-Path $installFolder
Remove $package

Write-Output "Node.js = $version" >> ~/versions.txt
