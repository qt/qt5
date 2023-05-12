# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script installs postgresql $version.
# Both x86 and x64 versions needed when x86 integrations are done on x64 machine

$version = "9.6.16-1"
$packagex64 = "C:\Windows\temp\postgresql-$version-windows-x64-binaries.zip"
$packagex86 = "C:\Windows\temp\postgresql-$version-windows-binaries.zip"

if (Is64BitWinHost) {
    # Install x64 bit versions
    $architecture = "x64"
    $installFolder = "C:\Utils\postgresql"
    $externalUrl = "http://get.enterprisedb.com/postgresql/postgresql-$version-windows-x64-binaries.zip"
    $internalUrl = "\\ci-files01-hki.ci.qt.io\provisioning\windows\postgresql-$version-windows-x64-binaries.zip"
    $sha1 = "5dd604f91973112209362b5abbbd1220c026f645"

    Write-Host "Fetching from URL ..."
    Download $externalUrl $internalUrl $packagex64
    Verify-Checksum $packagex64 $sha1
    Write-Host "Installing $packagex64 ..."
    Extract-7Zip $packagex64 $installFolder "pgsql\lib pgsql\bin pgsql\share pgsql\include"

    Write-Host "Remove downloaded $packagex64 ..."
    Remove $packagex64
    # Remove pthread.h file so it won't be used in mingw builds (QTBUG-79555)
    Remove "$installFolder\pgsql\include\pthread.h"
    Remove "$installFolder\pgsql\include\unistd.h"

    Set-EnvironmentVariable "POSTGRESQL_INCLUDE_x64" "$installFolder\pgsql\include"
    Set-EnvironmentVariable "POSTGRESQL_LIB_x64" "$installFolder\pgsql\lib"
}

# Install x86 bit version
$architecture = "x86"
$externalUrl = "http://get.enterprisedb.com/postgresql/postgresql-$version-windows-binaries.zip"
$internalUrl = "\\ci-files01-hki.ci.qt.io\provisioning\windows\postgresql-$version-windows-binaries.zip"
$sha1 = "46309190e60eead99c2d39c1dd18a91f2104d000"
if (Is64BitWinHost) {
    $installFolder = "C:\Utils\postgresql$architecture"
} else {
    $installFolder = "C:\Utils\postgresql"
}


Write-Host "Fetching from URL..."
Download $externalUrl $internalUrl $packagex86
Verify-Checksum $packagex86 $sha1
Write-Host "Installing $packagex86 ..."
Extract-7Zip $packagex86 $installFolder "pgsql\lib pgsql\bin pgsql\share pgsql\include"

Write-Host "Remove downloaded $packagex86 ..."
Remove $packagex86
# Remove pthread.h file so it won't be used in mingw builds (QTBUG-79555)
Remove "$installFolder\pgsql\include\pthread.h"
Remove "$installFolder\pgsql\include\unistd.h"

Set-EnvironmentVariable "POSTGRESQL_INCLUDE_x86" "$installFolder\pgsql\include"
Set-EnvironmentVariable "POSTGRESQL_LIB_x86" "$installFolder\pgsql\lib"

# Store version information to ~/versions.txt, which is used to print version information to provision log.
Write-Output "PostgreSQL = $version" >> ~/versions.txt
