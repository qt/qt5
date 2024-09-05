# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

$majorminorversion = "3.27"
$version = "3.27.7"

$zip = Get-DownloadLocation ("cmake-" + $version + "-windows-i386.zip")
$officialurl = "https://cmake.org/files/v" + $majorminorversion + "/cmake-" + $version + "-windows-i386.zip"
$cachedurl = "\\ci-files01-hki.ci.qt.io\provisioning\cmake\cmake-" + $version + "-windows-i386.zip"

Write-Host "Removing old cmake"
Remove "C:\CMake"

Download $officialurl $cachedurl $zip
Verify-Checksum $zip "b6147215a5f9cd1138b012265229fbf2224d02c6"

Extract-7Zip $zip C:
$defaultinstallfolder = "C:\cmake-" + $version + "-windows-i386"
Rename-Item $defaultinstallfolder C:\CMake

Add-Path "C:\CMake\bin"

Write-Output "CMake = $version" >> ~\versions.txt

