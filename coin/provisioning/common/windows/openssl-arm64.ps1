#############################################################################
##
## Copyright (C) 2021 The Qt Company Ltd.
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

. "$PSScriptRoot\helpers.ps1"

# This script installs OpenSSL ARM64 $version.

##### OpenSSL ARM64 has been pre-built with following commands #####
# Two different builds were done to the same folder C:\openssl_arm64\. One with '--debug' and one with '--release' parameter
# From Visual studio 'C++ Universal Windows Platform support for v142 build tools (ARM64)' and 'Windows Universal C Runtime' were installed
# cd C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build
# call vcvarsamd64_arm64
#
# perl Configure no-asm VC-WIN64-ARM --debug --prefix=C:\openssl_arm64\ --openssldir=C:\openssl_arm64\
# nmake
# nmake install
#
# perl Configure no-asm VC-WIN64-ARM --release --prefix=C:\openssl_arm64\ --openssldir=C:\openssl_arm64\
# nmake
# nmake install
#################################################################################################################################################

$version = "1_1_1_k"
$url = "\\ci-files01-hki.intra.qt.io\provisioning\openssl\openssl-$version-arm64.zip"
$sha1 = "e31f6d3a4af225f9314830aad099bb8e5d4a7ff1"
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
