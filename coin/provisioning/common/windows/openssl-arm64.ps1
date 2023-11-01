# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script installs OpenSSL ARM64 $version.

##### OpenSSL ARM64 has been pre-built with following commands #####
# Two different builds were done to the same folder C:\openssl_arm64\. One with '--debug' and one with '--release' parameter
# From Visual studio 'C++ Universal Windows Platform support for v142 build tools (ARM64)' and 'Windows Universal C Runtime' were installed
# cd C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build
# call vcvarsamd64_arm64
# curl -o C:\Utils\openssl-3.0.7.zip http://ci-files01-hki.ci.qt.io/input/openssl/openssl-3.0.7.zip
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
$url = "\\ci-files01-hki.ci.qt.io\provisioning\openssl\openssl-$version-arm64.zip"
$sha1 = "19be15069d981b4a96f5715f039df7aaa7456d52"
$installFolder = "C:\openssl_arm64"
$zip_package = "C:\Windows\Temp\$version.zip"

Write-Host "Fetching from URL ..."
Download $url $url $zip_package
Verify-Checksum $zip_package $sha1
Extract-7Zip $zip_package C:\
Remove $zip_package

$cpu_arch = Get-CpuArchitecture
switch ($cpu_arch) {
    arm64 {
        # For native arm64
        Set-EnvironmentVariable "OPENSSL_ROOT_DIR_arm64" "$installFolder"
        Set-EnvironmentVariable "OPENSSL_CONF_arm64" "$installFolder\bin\openssl.cfg"
        Set-EnvironmentVariable "OPENSSL_INCLUDE_arm64" "$installFolder\include"
        Set-EnvironmentVariable "OPENSSL_LIB_arm64" "$installFolder\lib"
        Break
    }
    x64 {
        # For cross-compiling x64_arm64
        Set-EnvironmentVariable "OPENSSL_ROOT_DIR_x64_arm64" "$installFolder"
        Set-EnvironmentVariable "OPENSSL_CONF_x64_arm64" "$installFolder\bin\openssl.cfg"
        Set-EnvironmentVariable "OPENSSL_INCLUDE_x64_arm64" "$installFolder\include"
        Set-EnvironmentVariable "OPENSSL_LIB_x64_arm64" "$installFolder\lib"
    }
    default {
        throw "Unknown architecture $cpu_arch"
    }
}

Prepend-Path "$installFolder\bin"

# Store version information to ~/versions.txt, which is used to print version information to provision log.
Write-Output "OpenSSL ARM= $version" >> ~/versions.txt
