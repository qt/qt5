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

# This script will install Node.js
# Needed by QtWebengine

$version = "12.18.0"
$package = "C:\Windows\temp\nodejs-$version.zip"
$targetFolder = "C:\Utils\nodejs"
$arch = "$((Get-WmiObject Win32_Processor).AddressWidth)"
$externalUrl = "https://nodejs.org/dist/v$version/node-v$version-win-x$arch.zip"
$internalUrl = "http://ci-files01-hki.intra.qt.io/input/windows/node-v$version-win-x$arch.zip"

if ( $arch -eq 64 ) {
    $sha1 = "457b1527d249ee471a9445953a906cb10c75378d"
} else {
    $sha1 = "58801900f5bddca9c00feed6b84fed729426fc92"

}

Write-Host "Installing Node.js"
Download $externalUrl $internalUrl $package
Verify-Checksum $package $sha1
mkdir $targetFolder
Extract-7Zip $package $targetFolder
Add-Path $targetFolder
Remove $package

Write-Output "Node.js = $version" >> ~/versions.txt
