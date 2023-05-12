# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script installs 7-Zip

$version = "16.04"
$nonDottedVersion = "1604"

if (Is64BitWinHost) {
    $arch = "-x64"
    $sha1 = "338A5CC5200E98EDD644FC21807FDBE59910C4D0"
} else {
    $arch = ""
    $sha1 = "dd1cb1163c5572951c9cd27f5a8dd550b33c58a4"
}

$url_cache = "\\ci-files01-hki.intra.qt.io\provisioning\windows\7z" + $nonDottedVersion + $arch + ".exe"
$url_official = "http://www.7-zip.org/a/7z" + $nonDottedVersion + $arch + ".exe"
$7zPackage = "C:\Windows\Temp\7zip-$nonDottedVersion.exe"
$7zTargetLocation = "C:\Utils\sevenzip\"

Download $url_official $url_cache $7zPackage
Verify-Checksum $7zPackage $sha1
Run-Executable $7zPackage "/S","/D=$7zTargetLocation"

Write-Host "Cleaning $7zPackage.."
Remove "$7zPackage"

Add-Path $7zTargetLocation

Write-Output "7-Zip = $version" >> ~\versions.txt
