#############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
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

# This script installs postgresql $version.
# Both x86 and x64 versions needed when x86 integrations are done on x64 machine

$version = "9.1.9-1"
$packagex64 = "C:\Windows\temp\postgresql-$version-windows-x64-binaries.zip"
$packagex86 = "C:\Windows\temp\postgresql-$version-windows-binaries.zip"

if( (is64bitWinHost) -eq 1 ) {
    # Install x64 bit versions
    $architecture = "x64"
    $installFolder = "C:\Utils\postgresql\pgsql"
    $externalUrl = "http://get.enterprisedb.com/postgresql/postgresql-$version-windows-x64-binaries.zip"
    $internalUrl = "\\ci-files01-hki.intra.qt.io\provisioning\windows\postgresql-$version-windows-x64-binaries.zip"
    $sha1 = "4da0453cdfda335e064d4437cf5bb9d356054cfd"

    # Delete any leftovers
    try {
        Rename-Item -ErrorAction 'Stop' c:\utils\postgresql c:\utils\postgresql-deleted
    } catch {}

    echo "Fetching from URL ..."
    Download $externalUrl $internalUrl $packagex64
    Verify-Checksum $packagex64 $sha1
    echo "Installing $packagex64 ..."
    Extract-Dev-Folders-From-Zip $packagex64 "pgsql" $installFolder

    echo "Remove downloaded $packagex64 ..."
    Remove-Item $packagex64

    echo "Set $architecture environment variables ..."
    [Environment]::SetEnvironmentVariable("POSTGRESQL_INCLUDE_x64", "$installFolder\include", "Machine")
    [Environment]::SetEnvironmentVariable("POSTGRESQL_LIB_x64", "$installFolder\lib", "Machine")
}

# Install x86 bit version
$architecture = "x86"
$externalUrl = "http://get.enterprisedb.com/postgresql/postgresql-$version-windows-binaries.zip"
$internalUrl = "\\ci-files01-hki.intra.qt.io\provisioning\windows\postgresql-$version-windows-binaries.zip"
$sha1 = "eb4f01845e1592800edbb74f60944b6c0aca51a9"
if( (is64bitWinHost) -eq 1 ) {
    $installFolder = "C:\Utils\postgresql$architecture\pgsql"
}
else {
    $installFolder = "C:\Utils\postgresql\pgsql"
}


echo "Fetching from URL..."
Download $externalUrl $internalUrl $packagex86
Verify-Checksum $packagex86 $sha1
echo "Installing $packagex86 ..."
Extract-Dev-Folders-From-Zip $packagex86 "pgsql" $installFolder

echo "Remove downloaded $packagex86 ..."
Remove-Item $packagex86

echo "Set $architecture environment variables ..."
[Environment]::SetEnvironmentVariable("POSTGRESQL_INCLUDE_x86", "$installFolder\include", "Machine")
[Environment]::SetEnvironmentVariable("POSTGRESQL_LIB_x86", "$installFolder\lib", "Machine")

# Store version information to ~/versions.txt, which is used to print version information to provision log.
echo "PostgreSQL = $version" >> ~/versions.txt
