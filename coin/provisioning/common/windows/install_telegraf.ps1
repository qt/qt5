# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\..\..\common\windows\helpers.ps1"


# Install a specific version of Telegraf
# https://github.com/influxdata/telegraf/releases

$version = "1.12.6" # TODO: ARM is not supported in this version
$has_telegraf_ver = $false

$cpu_arch = Get-CpuArchitecture
switch ($cpu_arch) {
    arm64 {
        $arch = "arm64"
        $sha256 = "5925642aad9a35886b172050203287cf33078313f543021781885ed94d9cbcff"
        $version = "1.29.4" # TODO: ARM needs this, update this to all
        $has_telegraf_ver = $true
        Break
    }
    x64 {
        $arch = "amd64"
        $sha256 = "5d025d85070e8c180c443580afa8a27421a7bbcf14b5044894e9f3298d0ce97a"
        Break
    }
    x86 {
        $arch = "i386"
        $sha256 = "5178a0bdaab448c2ef965b0e36f835849cea731ccd87c4a4527f0f05fbbdf271"
        Break
    }
    default {
        throw "Unknown architecture $cpu_arch"
    }
}

$telegraf_ver = "telegraf-" + $version
$filename_zip = $telegraf_ver + "_windows_" + $arch + ".zip"

$url_cache = "http://ci-files01-hki.ci.qt.io/input/telegraf/" + $filename_zip
$url_official = "https://dl.influxdata.com/telegraf/releases/" + $filename_zip
$tempfile = "C:\Windows\Temp\" + $filename_zip

Write-Host "Fetching Telegraf $version..."
Download $url_official $url_cache $tempfile
Verify-Checksum $tempfile $sha256 sha256

Write-Host "Installing telegraf.exe under C:\Utils\telegraf"

if ($has_telegraf_ver -eq $true) {
    Extract-7Zip $tempfile C:\Utils
    Rename-Item "C:\Utils\$telegraf_ver" "C:\Utils\telegraf"
} else {
    Extract-7Zip $tempfile C:\Utils "telegraf"
}

Copy-Item "$PSScriptRoot\..\..\common\windows\telegraf-coin.conf" C:\telegraf-coin.conf

. "$PSScriptRoot\telegraf_password.ps1"

Start-Process -FilePath C:\Utils\telegraf\telegraf.exe -ArgumentList "--config C:\telegraf-coin.conf"

Write-Output "Telegraf = $version" >> ~\versions.txt
