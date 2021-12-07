#############################################################################
##
## Copyright (C) 2021 The Qt Company Ltd.
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

# This script will install Google's Protocol Buffers
# Script requires Cmake to be installed and strawberry-perl not to be installed

$version = "3.6.1"
$sha1 = "44b8ba225f3b4dc45fb56d5881ec6a91329802b6"
$officialUrl = "https://github.com/protocolbuffers/protobuf/releases/download/v$version/protobuf-all-$version.zip"
$cachedUrl = "http://ci-files01-hki.intra.qt.io/input/automotive_suite/protobuf-all-$version.zip"
$zip = "C:\Utils\protobuf-all-$version.zip"
$installationFolder = "C:\Utils\protobuf"

Write-Host "Installing Protocol Buffers"
Add-Path "C:\CMake\bin"
Download "$officialUrl" "$cachedUrl" "$zip"
Verify-Checksum "$zip" "$sha1"
Extract-7Zip "$zip" C:\Utils
New-Item -ItemType directory -Force -Path "C:\Utils\protobuf-$version\cmake\build"
New-Item -ItemType directory -Force -Path "C:\Utils\protobuf-$version\cmake\build\release"
New-Item -ItemType directory -Force -Path "$installationFolder"
cd "C:\Utils\protobuf-$version\cmake\build\release"
cmd /c "`"C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\Professional\\VC\\Auxiliary\\Build\\vcvars64.bat`" && cmake -G `"NMake Makefiles`" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$installationFolder ../.. && nmake && nmake install"
if(![System.IO.File]::Exists("$installationFolder\bin\protoc.exe")){
    Write-Host "Can't find $installationFolder\bin\protoc.exe. Installation probably failed!"
    exit 1
}

Remove "$zip"

Add-Path "$installationFolder\bin"
Set-EnvironmentVariable PROTOBUF_INCLUDE "$installationFolder\include"
Set-EnvironmentVariable PROTOBUF_LIB "$installationFolder\lib"
