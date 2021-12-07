#############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
## Copyright (C) 2017 Pelagicore AG
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

# This script installs Visual C++ Redistributable for Visual Studio 2015
# This is a dependency of the current python3 version

if (Is64BitWinHost) {
    Write-Host "Running in 64 bit system"
    $arch = "x64"
    $externalUrl = "https://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vc_redist.x64.exe"
    $internalUrl = "http://ci-files01-hki.intra.qt.io/input/windows/vc_redist.x64.exe"
    $sha1 = "3155cb0f146b927fcc30647c1a904cd162548c8c"
} else {
    $arch = "x86"
    $externalUrl = "https://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vc_redist.x86.exe"
    $internalUrl = "http://ci-files01-hki.intra.qt.io/input/windows/vc_redist.x86.exe"
    $sha1 = "bfb74e498c44d3a103ca3aa2831763fb417134d1"
}

$package = "C:\Windows\temp\vc_redist.$arch.exe"

Write-Host "Fetching from URL..."
Download $externalUrl $internalUrl $package
Verify-Checksum $package $sha1
Write-Host "Installing $package..."
Run-Executable $package "/q"
Remove $package
