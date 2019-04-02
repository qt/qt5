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
. "$PSScriptRoot\helpers.ps1"

# This script will install vcpkg

$version = "08ad9d88ecabf9f8111bd4df0ca74723550503cd"
$sha1 = "43b471aebc2f46bee00c86710d0311ef6fb7bb19"
$officialUrl = "https://codeload.github.com/liangqi/vcpkg/zip/qt"
$cachedUrl = "http://ci-files01-hki.ci.local/input/vcpkg/vcpkg-$version.zip"
$zip = "C:\Utils\vcpkg-$version.zip"
$installationFolder = "C:\Utils\vcpkg"

Write-Host "Installing vcpkg"
Download "$officialUrl" "$cachedUrl" "$zip"
Verify-Checksum "$zip" "$sha1"
Extract-7Zip "$zip" C:\Utils
cmd /c mklink /d "$installationFolder" "C:\Utils\vcpkg-qt"
cd "C:\Utils\vcpkg-qt\"
cmd /c "`"C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\Professional\\VC\\Auxiliary\\Build\\vcvars64.bat`" && bootstrap-vcpkg.bat"

if(![System.IO.File]::Exists("$installationFolder\vcpkg.exe")){
    Write-Host "Can't find $installationFolder\vcpkg.exe. Installation probably failed!"
    exit 1
}

Set-EnvironmentVariable VCPKG_DEFAULT_TRIPLET "x64-windows"
Set-EnvironmentVariable VCPKG_CMAKE_TOOLCHAIN_FILE "$installationFolder\scripts\buildsystems\vcpkg.cmake"

# pcre2-16.dll was used when generating qvulkanfunctions.h
Add-Path "C:\Utils\vcpkg\installed\x64-windows\bin"

cmd /c "`"C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\Professional\\VC\\Auxiliary\\Build\\vcvars64.bat`" && $installationFolder\vcpkg.exe --triplet x64-windows install zlib pcre2 double-conversion harfbuzz openssl"

Remove-Item "$zip"
