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

. "$PSScriptRoot\..\common\helpers.ps1"

# This script installs MySQL $version.
# Both x86 and x64 versions needed when x86 integrations are done on x64 machine

$version = "5.6.11"
$packagex64 = "C:\Windows\temp\mysql-$version-win64.zip"
$packagex86 = "C:\Windows\temp\mysql-$version-win32.zip"

function CheckAndRemovePreviousInstallation
{
    Param (
        [string]$InstallFolder
    )
    echo "Check for previous installation..."
    $FolderExists = Test-Path $ExistingInstallation
    If ($FolderExists -eq $True) {
        echo "Removing previous installation ($ExistingInstallation)"
        Remove-Item $ExistingInstallation -recurse
    }
}

function DownloadAndInstall
{
    Param (
        [string]$arch,
        [string]$externalUrl,
        [string]$internalUrl,
        [string]$package,
        [string]$sha1,
        [string]$installPath
    )

   echo "Fetching from URL ..."
   Download $externalUrl $internalUrl $package
   Verify-Checksum $package $sha1
   Extract-Zip $package $installPath
}

# Install x64 bit version
$architecture = "x64"
$installFolder = "C:\Utils\my_sql"
$existingInstallation = "$installFolder\my_sql"
$internalUrl = "http://ci-files01-hki.ci.local/input/windows/mysql-$version-winx64"
$sha1 = "f4811512b5f3c8ad877ee4feba2062312a0acc38"

echo "Check and remove previous installation ..."
CheckAndRemovePreviousInstallation $existingInstallation
DownloadAndInstall $architecture $internalUrl $internalUrl $packagex64 $sha1 $installFolder
Rename-Item -path $installFolder\mysql-$version-winx64 -newName $installFolder\my_sql

echo "Remove downloaded package ..."
Remove-Item $packagex64

echo "Set environment variables ..."
[Environment]::SetEnvironmentVariable("MYSQL_INCLUDE_x64", "$installFolder\my_sql\include", "Machine")
[Environment]::SetEnvironmentVariable("MYSQL_LIB_x64", "$installFolder\my_sql\lib", "Machine")

# Install x86 bit version
$architecture = "x86"
$installFolder = "C:\Utils\my_sql$architecture"
$existingInstallation = "$installFolder\my_sql"
$internalUrl = "http://ci-files01-hki.ci.local/input/windows/mysql-$version-win32"
$sha1 = "e0aa62d5c5d6c6ec28906a831752d04336562679"

echo "Check and remove previous installation ..."
CheckAndRemovePreviousInstallation $existingInstallation
DownloadAndInstall $architecture $internalUrl $internalUrl $packagex86 $sha1 $installFolder
Rename-Item -path $installFolder\mysql-$version-win32 -newName $installFolder\my_sql

echo "Remove downloaded package ..."
Remove-Item $packagex86

echo "Set environment variables ..."
[Environment]::SetEnvironmentVariable("MYSQL_INCLUDE_x86", "$installFolder\my_sql\include", "Machine")
[Environment]::SetEnvironmentVariable("MYSQL_LIB_x86", "$installFolder\my_sql\lib", "Machine")

# Store version information to ~/versions.txt, which is used to print version information to provision log.
echo "MySQL = $version" >> ~/versions.txt
