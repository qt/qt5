#############################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
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

# This script installs MySQL $version.
# Both x86 and x64 versions needed when x86 integrations are done on x64 machine

$version = "5.7.25"
$baseNameX64 = "mysql-$version-winx64"
$packagex64 = "C:\Windows\temp\$baseNameX64.zip"
$baseNameX86 = "mysql-$version-win32"
$packagex86 = "C:\Windows\temp\$baseNameX86.zip"
$installFolder = "C:\Utils\my_sql"

function DownloadAndInstall
{
    Param (
        [string]$internalUrl,
        [string]$package,
        [string]$installPath
    )

    Write-Host "Fetching from URL ..."
    Copy-Item $internalUrl $package

    $zipDir = [io.path]::GetFileNameWithoutExtension($package)
    Extract-7Zip $package $installPath "$zipDir\lib $zipDir\bin $zipDir\share $zipDir\include"

    Remove "$package"
}

if (Is64BitWinHost) {
    # Install x64 bit version
    $architecture = "x64"
    $internalUrl = "\\ci-files01-hki.intra.qt.io\provisioning\windows\mysql-$version-winx64.zip"

    DownloadAndInstall $internalUrl $packagex64 $installFolder

    Set-EnvironmentVariable "MYSQL_INCLUDE_x64" "$installFolder\$baseNameX64\include"
    Set-EnvironmentVariable "MYSQL_LIB_x64" "$installFolder\$baseNameX64\lib"
}

# Install x86 bit version
$architecture = "x86"
$internalUrl = "\\ci-files01-hki.intra.qt.io\provisioning\windows\mysql-$version-win32.zip"
DownloadAndInstall $internalUrl $packagex86 $installFolder

Set-EnvironmentVariable "MYSQL_INCLUDE_x86" "$installFolder\$baseNameX86\include"
Set-EnvironmentVariable "MYSQL_LIB_x86" "$installFolder\$baseNameX86\lib"

# Store version information to ~/versions.txt, which is used to print version information to provision log.
Write-Output "MySQL = $version" >> ~/versions.txt
