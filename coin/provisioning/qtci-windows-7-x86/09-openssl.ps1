#############################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
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

. "$PSScriptRoot\..\common\windows\helpers.ps1"

# This script will install OpenSSL prebuild version. Currently this pre-build version is only needed for Windows 7.
# Version was build using Windows 7 x86 and MSVC2010

# Used build commands below:
# call "C:\Program Files\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86
# perl Configure no-asm VC-WIN32 --prefix=C:\openssl\ --openssldir=C:\openssl\
# nmake
# nmake install


$version = "1.1.1g"
$zip = Get-DownloadLocation ("openssl-$version.7z")
$sha1 = "e94263ba067a5cc0ace17e26bb2f98c62d298b5a"
$url = "http://ci-files01-hki.intra.qt.io/input/openssl/openssl_${version}_prebuild_x86_windows7_msvc2010.zip"

Download $url $url $zip
Verify-Checksum $zip $sha1
$installFolder = "C:\openssl"

Extract-7Zip $zip "C:\"
Remove-Item -Path $zip

Move-Item -Path C:\openssl_${version}_prebuild_x86_windows7_msvc2010 -Destination C:\openssl

Set-EnvironmentVariable "OPENSSL_CONF_x86" "$installFolder\openssl.cnf"
Set-EnvironmentVariable "OPENSSL_INCLUDE_x86" "$installFolder\include"
Set-EnvironmentVariable "OPENSSL_LIB_x86" "$installFolder\lib"
Prepend-Path "$installFolder\bin"

Write-Output "OpenSSL = $version" >> ~/versions.txt
