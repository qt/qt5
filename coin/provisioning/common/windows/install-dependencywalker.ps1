# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install Dependency Walker 2.2.6000

$version = "2.2.6000"
if (Is64BitWinHost) {
    $arch = "_x64"
    $sha1 = "4831D2A8376D64110FF9CD18799FE6C69509D3EA"
} else {
    $arch = "_x86"
    $sha1 = "bfec714057e8449b0246051be99ba46a7760bab9"
}
$url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\depends22" + $arch + ".zip"
$url_official = "http://www.dependencywalker.com/depends22" + $arch + ".zip"
$dependsPackage = "C:\Windows\Temp\depends-$version.zip"

$TARGETDIR = "C:\Utils\dependencywalker"
if (!(Test-Path -Path $TARGETDIR )) {
    New-Item -ItemType directory -Path $TARGETDIR
}
Download $url_official $url_cache $dependsPackage
Verify-Checksum $dependsPackage $sha1

Extract-7Zip $dependsPackage $TARGETDIR

# Copy the content also into the cache location of nuitka
# This makes it usable without the need to download it again
Copy-Item -Path $TARGETDIR -Destination "$env:LOCALAPPDATA\Nuitka\Nuitka\Cache\downloads\depends\x86_64" -Recurse

Write-Host "Cleaning $dependsPackage.."
Remove "$dependsPackage"

Write-Output "Dependency Walker = $version" >> ~\versions.txt
