# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\..\..\common\windows\helpers.ps1"


# Install a specific version of Telegraf
# https://github.com/influxdata/telegraf/releases

$version = "1.12.6"

if (Is64BitWinHost) {
    $arch = "amd64"
    $sha256 = "5d025d85070e8c180c443580afa8a27421a7bbcf14b5044894e9f3298d0ce97a"
} else {
    $arch = "i386"
    $sha256 = "5178a0bdaab448c2ef965b0e36f835849cea731ccd87c4a4527f0f05fbbdf271"
}

$filename = "telegraf-" + $version + "_windows_" + $arch + ".zip"

$url_cache = "http://ci-files01-hki.intra.qt.io/input/telegraf/" + $filename
$url_official = "https://dl.influxdata.com/telegraf/releases/" + $filename
$tempfile = "C:\Windows\Temp\" + $filename

Write-Host "Fetching Telegraf $version..."
Download $url_official $url_cache $tempfile
Verify-Checksum $tempfile $sha256 sha256

Write-Host "Installing telegraf.exe under C:\Utils\telegraf"
Extract-7Zip $tempfile C:\Utils "telegraf"
Copy-Item "$PSScriptRoot\..\..\common\windows\telegraf-coin.conf" C:\telegraf-coin.conf

. "$PSScriptRoot\telegraf_password.ps1"

Start-Process -FilePath C:\Utils\telegraf\telegraf.exe -ArgumentList "--config C:\telegraf-coin.conf"

Write-Output "Telegraf = $version" >> ~\versions.txt
