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

. "$PSScriptRoot\helpers.ps1"

# This script installs Strawberry Perl

$version = "5.26.0.1"
if (Is64BitWinHost) {
    $arch = "-64bit"
    $sha1 = "2AE2EDA36A190701399130CBFEE04D00E9BA036D"
} else {
    $arch = "-32bit"
    $sha1 = "b50b688a879f33941433774b2813bfd4b917e4ee"
}
$installer_name = "strawberry-perl-" + $version + $arch + ".msi"
$url_cache = "\\ci-files01-hki.intra.qt.io\provisioning\windows\" + $installer_name
$url_official = "http://strawberryperl.com/download/" + $version + "/" + $installer_name
$strawberryPackage = "C:\Windows\Temp\" + $installer_name

Download $url_official $url_cache $strawberryPackage
Verify-Checksum $strawberryPackage $sha1
Run-Executable "msiexec" "/quiet /i $strawberryPackage INSTALLDIR=C:\strawberry REBOOT=REALLYSUPPRESS"

Write-Host "Cleaning $strawberryPackage.."
Remove-Item -Recurse -Force -Path "$strawberryPackage"

Write-Output "strawberry = $version" >> ~\versions.txt
