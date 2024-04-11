# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script installs OpenSSL x86_64 (debug version)

##### OpenSSL has been pre-built with following commands #####
# cd C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build
# call vcvarsamd64
# curl -o C:\Utils\openssl-3.5.4.zip http://ci-files01-hki.ci.qt.io/input/openssl/openssl-3.5.4.zip
# cd C:\Utils
# C:\Utils\sevenzip\7z.exe x C:\Utils\openssl-3.5.4.zip
# cd C:\Utils\openssl-3.5.4
# perl Configure VC-WIN64A --debug --prefix=C:\openssl_x64\
# nmake
# nmake install
####################################################################################################

$version = "3.5.4"
$url = "https://ci-files01-hki.ci.qt.io/input/openssl/openssl-$version-prebuild-windows-msvc2022-x64.zip"
$sha1 = "a028caa10ade0c1d39ad60d06201345908dfaaf2"
$installFolder = "C:\openssl_x64"
$zip_package = "C:\Windows\Temp\$version.zip"

Write-Host "Fetching from URL ..."
Download $url $url $zip_package
Verify-Checksum $zip_package $sha1
Extract-7Zip $zip_package C:\
Remove $zip_package

Set-EnvironmentVariable "OPENSSL_ROOT_DIR_x64" "$installFolder"
Set-EnvironmentVariable "OPENSSL_INCLUDE_x64" "$installFolder\include"
Set-EnvironmentVariable "OPENSSL_LIB_x64" "$installFolder\lib"

# Set envvars for builds in provisoning e.g. grpc
Set-EnvironmentVariable "OPENSSL_ROOT_DIR" "$installFolder"
Set-EnvironmentVariable "OPENSSL_INCLUDE" "$installFolder\include"
Set-EnvironmentVariable "OPENSSL_LIB" "$installFolder\lib"

Prepend-Path "$installFolder\bin"

# Store version information to ~/versions.txt, which is used to print version information to provision log.
Write-Output "OpenSSL x64= $version" >> ~/versions.txt
