#############################################################################
##
## Copyright (C) 2020 The Qt Company Ltd.
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

# This script will install Node.js
# Needed by QtWebengine

$version = "20.7.0"
if (Is64BitWinHost) {
    $arch = "x64"
    $sha256 = "b3e5cbf8e247c75f9ddd235d49cfe40f25dde65bdd0eec4cefbca2805d80376b"
} else {
    $arch = "x86"
    $sha256 = "d6a3c63a5ae71374c144a33c418ab96be497b08df0e9f51861a78127db03aeb5"
}

$package = "C:\Windows\temp\nodejs-$version.7z"
$targetFolder = "C:\Utils"
$installFolder = "C:\Utils\node-v$version-win-$arch"
$externalUrl = "https://nodejs.org/dist/v$version/node-v$version-win-$arch.7z"
$internalUrl = "http://ci-files01-hki.intra.qt.io/input/windows/node-v$version-win-$arch.7z"

Write-Host "Installing Node.js"
Download $externalUrl $internalUrl $package
Verify-Checksum $package $sha256 "sha256"
Extract-7Zip $package $targetFolder
Add-Path $installFolder
Remove $package

Write-Output "Node.js = $version" >> ~/versions.txt
