############################################################################
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

# Requires: 7z, perl and msys

. "$PSScriptRoot\helpers.ps1"

# OpenSSL need to be configured from sources for Android build in windows 7
# Msys need to be installed to target machine
# More info and building instructions can be found from http://doc.qt.io/qt-5/opensslsupport.html

$version = "1.0.2o"
$zip = Get-DownloadLocation ("openssl-$version.tar.gz")
$sha1 = "a47faaca57b47a0d9d5fb085545857cc92062691"
$destination = "C:\Utils\openssl-android-master"

Download https://www.openssl.org/source/openssl-$version.tar.gz \\ci-files01-hki.intra.qt.io\provisioning\openssl\openssl-$version.tar.gz $zip
Verify-Checksum $zip $sha1

Extract-7Zip $zip C:\Utils
Extract-7Zip C:\Utils\openssl-$version.tar C:\Utils
Rename-Item C:\Utils\openssl-$version $destination
Remove-Item -Path $zip
Remove-Item C:\Utils\openssl-$version.tar

Set-EnvironmentVariable "CC" "C:\utils\android-ndk-r10e\toolchains\arm-linux-androideabi-4.9\prebuilt\windows\bin\arm-linux-androideabi-gcc"
Set-EnvironmentVariable "AR" "C:\utils\android-ndk-r10e\toolchains\arm-linux-androideabi-4.9\prebuilt\windows\bin\arm-linux-androideabi-ar"
Set-EnvironmentVariable "ANDROID_DEV" "C:\utils\android-ndk-r10e\platforms\android-18\arch-arm\usr"

# Make sure configure for openssl has a "make" and "perl" available
$env:PATH = $env:PATH + ";C:\msys\1.0\bin;C:\strawberry\perl\bin"

Write-Host "Configuring OpenSSL $version for Android..."
Push-Location $destination
Run-Executable "C:\msys\1.0\bin\bash.exe" "-c `"c:/strawberry/perl/bin/perl Configure shared android`""
Pop-Location

# Following command is needed when using version 1.1.0. With version 1.1.0 msys is not needed.
# C:\mingw530\bin\mingw32-make.exe include\openssl\opensslconf.h

Write-Output "Android OpenSSL = $version" >> ~/versions.txt
