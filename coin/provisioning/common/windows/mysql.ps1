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

# This script installs MySQL $version.
# Both x86 and x64 versions needed when x86 integrations are done on x64 machine

$version = "5.6.11"
$packagex64 = "C:\Windows\temp\mysql-$version-winx64.zip"
$packagex86 = "C:\Windows\temp\mysql-$version-win32.zip"

function DownloadAndInstall
{
    Param (
        [string]$internalUrl,
        [string]$package,
        [string]$installPath
    )

    echo "Fetching from URL ..."
    Copy-Item $internalUrl $package

    $zipDir = [io.path]::GetFileNameWithoutExtension($package)
    Extract-Dev-Folders-From-Zip $package $zipDir $installPath

    Remove-Item $package
}

# Remove any leftovers
try {
    Rename-Item -ErrorAction 'Stop' c:\utils\my_sql c:\utils\mysql_deleted
} catch {}

if( (is64bitWinHost) -eq 1 ) {
    # Install x64 bit version
    $architecture = "x64"
    $installFolder = "C:\Utils\my_sql\my_sql"
    $internalUrl = "\\ci-files01-hki.intra.qt.io\provisioning\windows\mysql-$version-winx64.zip"

    DownloadAndInstall $internalUrl $packagex64 $installFolder

    echo "Set environment variables ..."
    [Environment]::SetEnvironmentVariable("MYSQL_INCLUDE_x64", "$installFolder\include", "Machine")
    [Environment]::SetEnvironmentVariable("MYSQL_LIB_x64", "$installFolder\lib", "Machine")
}

# Install x86 bit version
$architecture = "x86"
$internalUrl = "\\ci-files01-hki.intra.qt.io\provisioning\windows\mysql-$version-win32.zip"
if( (is64bitWinHost) -eq 1 ) {
    $installFolder = "C:\Utils\my_sql\my_sql$architecture"
}
else {
    $installFolder = "C:\Utils\my_sql\my_sql"
}

DownloadAndInstall $internalUrl $packagex86 $installFolder

echo "Set environment variables ..."
[Environment]::SetEnvironmentVariable("MYSQL_INCLUDE_x86", "$installFolder\include", "Machine")
[Environment]::SetEnvironmentVariable("MYSQL_LIB_x86", "$installFolder\lib", "Machine")

# Store version information to ~/versions.txt, which is used to print version information to provision log.
echo "MySQL = $version" >> ~/versions.txt
