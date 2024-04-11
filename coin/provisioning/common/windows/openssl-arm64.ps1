# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script installs OpenSSL ARM64 (debug version)

##### OpenSSL ARM64 and x64-arm64 has been pre-built with following commands #####
# From Visual studio 'C++ Universal Windows Platform support for v143 build tools' and 'Windows Universal C Runtime' were installed
# cd C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build
# call vcvarsamd64_arm64 (or vcvarsarm64 in Windows 11 arm64 OS)
# curl -o C:\Utils\openssl-3.5.4.zip http://ci-files01-hki.ci.qt.io/input/openssl/openssl-3.5.4.zip
# (or https://github.com/openssl/openssl/releases/download/openssl-3.5.4/openssl-3.5.4.tar.gz)
# cd C:\Utils
# C:\Utils\sevenzip\7z.exe x C:\Utils\openssl-3.5.4.zip
# cd C:\Utils\openssl-3.5.4
# perl Configure no-asm VC-WIN64-ARM --debug --prefix=C:\openssl_arm64\
# nmake
# nmake install
##################################################################################

$version = "3.5.4"

$url = "https://ci-files01-hki.ci.qt.io/input/openssl/openssl-$version-prebuild-windows-msvc2022-arm64.zip"
$sha1 = "e5fdf5c565e7c275fdfe877f31b387eb48da5d96"
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
        # Native arm64
        Set-EnvironmentVariable "OPENSSL_ROOT_DIR_arm64" "$installFolder"
        Set-EnvironmentVariable "OPENSSL_INCLUDE_arm64" "$installFolder\include"
        Set-EnvironmentVariable "OPENSSL_LIB_arm64" "$installFolder\lib"
        Break
    }
    x64 {
        # For cross-compiling x64_arm64
        Set-EnvironmentVariable "OPENSSL_ROOT_DIR_x64_arm64" "$installFolder"
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
