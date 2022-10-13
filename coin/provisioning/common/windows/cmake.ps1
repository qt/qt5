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

$majorminorversion = "3.24"
$version = "3.24.2"

$zip = Get-DownloadLocation ("cmake-" + $version + "-windows-i386.zip")
$officialurl = "https://cmake.org/files/v" + $majorminorversion + "/cmake-" + $version + "-windows-i386.zip"
$cachedurl = "\\ci-files01-hki.intra.qt.io\provisioning\cmake\cmake-" + $version + "-windows-i386.zip"

Write-Host "Removing old cmake"
Remove "C:\CMake"

Download $officialurl $cachedurl $zip
Verify-Checksum $zip "97e6cdedded7a7522f4f4a64d7545d0454b4fad5"

Extract-7Zip $zip C:
$defaultinstallfolder = "C:\cmake-" + $version + "-windows-i386"
Rename-Item $defaultinstallfolder C:\CMake

Add-Path "C:\CMake\bin"

Write-Output "CMake = $version" >> ~\versions.txt

