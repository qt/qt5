#############################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
## Contact: http://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL21$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see http://www.qt.io/terms-conditions. For further
## information use the contact form at http://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 2.1 or version 3 as published by the Free
## Software Foundation and appearing in the file LICENSE.LGPLv21 and
## LICENSE.LGPLv3 included in the packaging of this file. Please review the
## following information to ensure the GNU Lesser General Public License
## requirements will be met: https://www.gnu.org/licenses/lgpl.html and
## http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
##
## As a special exception, The Qt Company gives you certain additional
## rights. These rights are described in The Qt Company LGPL Exception
## version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
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
