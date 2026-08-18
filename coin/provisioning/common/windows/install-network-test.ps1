# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Install and run network test

. "$PSScriptRoot\helpers.ps1"

$networkTestLocation = "C:\Program Files"
$url_public="https://ci-files01-hki.ci.qt.io/input/networktestapp/CiNetworkTest-MSVC-2022-Windows-v1.2.tgz"
$sha1="C1D8871E610CF281E74E009DBE1BE5DA84B49807"
$download_location = "C:\Windows\Temp\network-test.tgz"

Write-Host "Fetching CiNetworkTest.exe..."

Download $url_public "" $download_location
Verify-Checksum $download_location $sha1
Extract-tar_gz $download_location $networkTestLocation
Remove $download_location

# start executable
$exePath = "$networkTestLocation\CiNetworkTest.exe"
& $exePath --warn-only
