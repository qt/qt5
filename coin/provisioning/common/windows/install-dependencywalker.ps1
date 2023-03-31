############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
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

# This script will install Dependency Walker 2.2.6000

$version = "2.2.6000"
if (Is64BitWinHost) {
    $arch = "_x64"
    $sha1 = "4831D2A8376D64110FF9CD18799FE6C69509D3EA"
} else {
    $arch = "_x86"
    $sha1 = "bfec714057e8449b0246051be99ba46a7760bab9"
}
$url_cache = "\\ci-files01-hki.intra.qt.io\provisioning\windows\depends22" + $arch + ".zip"
$url_official = "http://www.dependencywalker.com/depends22" + $arch + ".zip"
$dependsPackage = "C:\Windows\Temp\depends-$version.zip"

$TARGETDIR = "C:\Utils\dependencywalker"
if (!(Test-Path -Path $TARGETDIR )) {
    New-Item -ItemType directory -Path $TARGETDIR
}
Download $url_official $url_cache $dependsPackage
Verify-Checksum $dependsPackage $sha1

Extract-7Zip $dependsPackage $TARGETDIR

# Copy the content also into the cache location of nuitka
# This makes it usable without the need to download it again
Copy-Item -Path $TARGETDIR -Destination "$env:LOCALAPPDATA\Nuitka\Nuitka\Cache\downloads\depends\x86_64" -Recurse

Write-Host "Cleaning $dependsPackage.."
Remove "$dependsPackage"

Write-Output "Dependency Walker = $version" >> ~\versions.txt
