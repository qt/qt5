############################################################################
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

# This script installs Strawberry Perl

$version = "5.32.0.1"
if (Is64BitWinHost) {
    $arch = "-64bit"
    $sha1 = "9ec5ebc865da82eacc2d95ff2976492ca69934ab"
} else {
    $arch = "-32bit"
    $sha1 = "6ad89c6358a174c048f113bfd274d2d0378d60aa"
}
$installer_name = "strawberry-perl-" + $version + $arch + ".msi"
$url_cache = "\\ci-files01-hki.intra.qt.io\provisioning\windows\" + $installer_name
$url_official = "http://strawberryperl.com/download/" + $version + "/" + $installer_name
$strawberryPackage = "C:\Windows\Temp\" + $installer_name

Download $url_official $url_cache $strawberryPackage
Verify-Checksum $strawberryPackage $sha1
Run-Executable "msiexec" "/quiet /i $strawberryPackage INSTALLDIR=C:\strawberry REBOOT=REALLYSUPPRESS"

Write-Host "Cleaning $strawberryPackage.."
Remove "$strawberryPackage"

Write-Output "strawberry = $version" >> ~\versions.txt
