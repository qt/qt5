# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script installs OpenSSL $version.
# Both x86 and x64 versions needed when x86 integrations are done on x64 machine

$version = "3_0_7"
$packagex64 = "C:\Windows\Temp\Win64OpenSSL-$version.exe"
$packagex86 = "C:\Windows\Temp\Win32OpenSSL-$version.exe"

if (Is64BitWinHost) {

    # Install x64 bit version
    $architecture = "x64"
    $installFolder = "C:\openssl"
    $externalUrl = "https://slproweb.com/download/Win64OpenSSL-$version.exe"
    $internalUrl = "\\ci-files01-hki.ci.qt.io\provisioning\openssl\Win64OpenSSL-$version.exe"
    $sha1 = "2fb73f233bc565939312782b8157bebc26a5e17b"

    Write-Host "Fetching from URL ..."
    Download $externalUrl $internalUrl $packagex64
    Verify-Checksum $packagex64 $sha1
    Write-Host "Installing $packagex64 ..."
    Run-Executable "$packagex64" "/SP- /SILENT /LOG /SUPPRESSMSGBOXES /NORESTART /DIR=$installFolder"

    Write-Host "Remove downloaded $packagex64 ..."
    Remove "$packagex64"

    Set-EnvironmentVariable "OPENSSL_CONF_x64" "$installFolder\bin\openssl.cfg"
    Set-EnvironmentVariable "OPENSSL_INCLUDE_x64" "$installFolder\include"
    Set-EnvironmentVariable "OPENSSL_LIB_x64" "$installFolder\lib"
    Prepend-Path "$installFolder\bin"
}

# Install x86 bit version
$architecture = "x86"

if (Is64BitWinHost) {
    $installFolder = "C:\openssl$architecture"
} else {
    $installFolder = "C:\openssl"
}

$externalUrl = "https://slproweb.com/download/Win32OpenSSL-$version.exe"
$internalUrl = "\\ci-files01-hki.ci.qt.io\provisioning\openssl\Win32OpenSSL-$version.exe"
$sha1 = "ddead693fa279ad6b1baf123b3af51a9ef289dc1"

Write-Host "Fetching from URL ..."
Download $externalUrl $internalUrl $packagex86
Verify-Checksum $packagex86 $sha1
Write-Host "Installing $packagex86 ..."
Run-Executable "$packagex86" "/SP- /SILENT /LOG /SUPPRESSMSGBOXES /NORESTART /DIR=$installFolder"

Write-Host "Remove downloaded $packagex86 ..."
Remove "$packagex86"

Set-EnvironmentVariable "OPENSSL_CONF_x86" "$installFolder\bin\openssl.cfg"
Set-EnvironmentVariable "OPENSSL_INCLUDE_x86" "$installFolder\include"
Set-EnvironmentVariable "OPENSSL_LIB_x86" "$installFolder\lib"

# Store version information to ~/versions.txt, which is used to print version information to provision log.
Write-Output "OpenSSL = $version" >> ~/versions.txt
