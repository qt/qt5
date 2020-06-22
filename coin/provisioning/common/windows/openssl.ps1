#############################################################################
##
## Copyright (C) 2020 The Qt Company Ltd.
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

# This script installs OpenSSL $version.
# Both x86 and x64 versions needed when x86 integrations are done on x64 machine

$version = "1_1_1g"
$packagex64 = "C:\Windows\Temp\Win64OpenSSL-$version.exe"
$packagex86 = "C:\Windows\Temp\Win32OpenSSL-$version.exe"

if (Is64BitWinHost) {

    # Install x64 bit version
    $architecture = "x64"
    $installFolder = "C:\openssl"
    $externalUrl = "https://slproweb.com/download/Win64OpenSSL-$version.exe"
    $internalUrl = "\\ci-files01-hki.intra.qt.io\provisioning\openssl\Win64OpenSSL-$version.exe"
    $sha1 = "7643561c372720f55de51454a707ede334db086e"

    Write-Host "Fetching from URL ..."
    Download $externalUrl $internalUrl $packagex64
    Verify-Checksum $packagex64 $sha1
    Write-Host "Installing $packagex64 ..."
    Run-Executable "$packagex64" "/SP- /SILENT /LOG /SUPPRESSMSGBOXES /NORESTART /DIR=$installFolder"

    Write-Host "Remove downloaded $packagex64 ..."
    Remove-Item -Path $packagex64

    Set-EnvironmentVariable "OPENSSL_CONF_x64" "$installFolder\bin\openssl.cfg"
    Set-EnvironmentVariable "OPENSSL_INCLUDE_x64" "$installFolder\include"
    Set-EnvironmentVariable "OPENSSL_LIB_x64" "$installFolder\lib"
}

# Install x86 bit version
$architecture = "x86"

if (Is64BitWinHost) {
    $installFolder = "C:\openssl$architecture"
} else {
    $installFolder = "C:\openssl"
}

$externalUrl = "https://slproweb.com/download/Win32OpenSSL-$version.exe"
$internalUrl = "\\ci-files01-hki.intra.qt.io\provisioning\openssl\Win32OpenSSL-$version.exe"
$sha1 = "c7d4b096c2413d1af819ccb291214fa3c4cece07"

Write-Host "Fetching from URL ..."
Download $externalUrl $internalUrl $packagex86
Verify-Checksum $packagex86 $sha1
Write-Host "Installing $packagex86 ..."
Run-Executable "$packagex86" "/SP- /SILENT /LOG /SUPPRESSMSGBOXES /NORESTART /DIR=$installFolder"

Write-Host "Remove downloaded $packagex86 ..."
Remove-Item -Path $packagex86

Set-EnvironmentVariable "OPENSSL_CONF_x86" "$installFolder\bin\openssl.cfg"
Set-EnvironmentVariable "OPENSSL_INCLUDE_x86" "$installFolder\include"
Set-EnvironmentVariable "OPENSSL_LIB_x86" "$installFolder\lib"

# Store version information to ~/versions.txt, which is used to print version information to provision log.
Write-Output "OpenSSL = $version" >> ~/versions.txt
