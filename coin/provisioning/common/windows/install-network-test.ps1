# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Install and run network test

. "$PSScriptRoot\helpers.ps1"

$networkTestLocation = "C:\Program Files"
$url_public="https://ci-files01-hki.ci.qt.io/input/networktestapp/CiNetworkTest-MSVC-2022-Windows.tgz"
$sha1="543D4562159140D4E7223721AF15ED6E1998E5B5"
$download_location = "C:\Windows\Temp\network-test.tgz"

Write-Host "Fetching CiNetworkTest.exe..."

Download $url_public "" $download_location
Verify-Checksum $download_location $sha1
Extract-tar_gz $download_location $networkTestLocation
Remove $download_location

# start executable
$exePath = "$networkTestLocation\CiNetworkTest.exe"
& $exePath --warn-only
