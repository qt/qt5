#############################################################################
##
## Copyright (C) 2022 The Qt Company Ltd.
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

. "$PSScriptRoot\helpers.ps1"

# This script installs OpenSSL ARM64 $version.

##### OpenSSL ARM64 has been pre-built with following commands #####
# Two different builds were done to the same folder C:\openssl_arm64\. One with '--debug' and one with '--release' parameter
# From Visual studio 'C++ Universal Windows Platform support for v142 build tools (ARM64)' and 'Windows Universal C Runtime' were installed
# cd C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build
# call vcvarsamd64_arm64
# curl -o C:\Utils\openssl-3.0.7.zip http://ci-files01-hki.intra.qt.io/input/openssl/openssl-3.0.7.zip
# cd C:\Utils
# C:\Utils\sevenzip\7z.exe x C:\Utils\openssl-3.0.7.zip
# cd C:\Utils\openssl-3.0.7
# perl Configure no-asm VC-WIN64-ARM --debug --prefix=C:\openssl_arm64\ --openssldir=C:\openssl_arm64\
# nmake
# nmake install
#
# perl Configure no-asm VC-WIN64-ARM --release --prefix=C:\openssl_arm64\ --openssldir=C:\openssl_arm64\
# nmake
# nmake install
#################################################################################################################################################

$version = "3_0_7"
$url = "\\ci-files01-hki.intra.qt.io\provisioning\openssl\openssl-$version-arm64.zip"
$sha1 = "19be15069d981b4a96f5715f039df7aaa7456d52"
$installFolder = "C:\openssl_arm64"
$zip_package = "C:\Windows\Temp\$version.zip"

Write-Host "Fetching from URL ..."
Download $url $url $zip_package
Verify-Checksum $zip_package $sha1
Extract-7Zip $zip_package C:\
Remove $zip_package

Set-EnvironmentVariable "OPENSSL_ROOT_DIR_x64_arm64" "$installFolder"
Set-EnvironmentVariable "OPENSSL_CONF_x64_arm64" "$installFolder\bin\openssl.cfg"
Set-EnvironmentVariable "OPENSSL_INCLUDE_x64_arm64" "$installFolder\include"
Set-EnvironmentVariable "OPENSSL_LIB_x64_arm64" "$installFolder\lib"

# Store version information to ~/versions.txt, which is used to print version information to provision log.
Write-Output "OpenSSL ARM= $version" >> ~/versions.txt
