#############################################################################
##
## Copyright (C) 2020 The Qt Company Ltd.
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
    $internalUrl = "\\ci-files01-hki.intra.qt.io\provisioning\windows\postgresql-$version-windows-x64-binaries.zip"
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
$internalUrl = "\\ci-files01-hki.intra.qt.io\provisioning\windows\postgresql-$version-windows-binaries.zip"
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
