#############################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
## Contact: https://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see https://www.qt.io/terms-conditions. For further
## information use the contact form at https://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 3 as published by the Free Software
## Foundation and appearing in the file LICENSE.LGPL3 included in the
## packaging of this file. Please review the following information to
## ensure the GNU Lesser General Public License version 3 requirements
## will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 2.0 or (at your option) the GNU General
## Public license version 3 or any later version approved by the KDE Free
## Qt Foundation. The licenses are as published by the Free Software
## Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
## included in the packaging of this file. Please review the following
## information to ensure the GNU General Public License requirements will
## be met: https://www.gnu.org/licenses/gpl-2.0.html and
## https://www.gnu.org/licenses/gpl-3.0.html.
##
## $QT_END_LICENSE$
##
#############################################################################

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
