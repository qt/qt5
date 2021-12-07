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

# This script will install Ruby

$version = "2.4.2-2"
if (Is64BitWinHost) {
    $arch = "-x64"
    $sha1 = "c961c2752a183487bc42ed24beb7e931230fa7d5"
} else {
    $arch = "-x86"
    $sha1 = "2639a481c3b5ad11f57d5523cc41ca884286089e"
}
$url_cache = "\\ci-files01-hki.intra.qt.io\provisioning\windows\rubyinstaller-" + $version + $arch + ".exe"
$url_official = "https://github.com/oneclick/rubyinstaller2/releases/download/rubyinstaller-" + $version + "/rubyinstaller-" + $version + $arch + ".exe"
$rubyPackage = "C:\Windows\Temp\rubyinstaller-$version.exe"

Download $url_official $url_cache $rubyPackage
Verify-Checksum $rubyPackage $sha1
Run-Executable $rubyPackage "/dir=C:\Ruby-$version$arch /tasks=modpath /verysilent"

Write-Host "Cleaning $rubyPackage.."
Remove "$rubyPackage"

Write-Output "Ruby = $version" >> ~\versions.txt
