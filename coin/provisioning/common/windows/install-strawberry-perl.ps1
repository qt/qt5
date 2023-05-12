# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

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
$url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\" + $installer_name
$url_official = "http://strawberryperl.com/download/" + $version + "/" + $installer_name
$strawberryPackage = "C:\Windows\Temp\" + $installer_name

Download $url_official $url_cache $strawberryPackage
Verify-Checksum $strawberryPackage $sha1
Run-Executable "msiexec" "/quiet /i $strawberryPackage INSTALLDIR=C:\strawberry REBOOT=REALLYSUPPRESS"

Write-Host "Cleaning $strawberryPackage.."
Remove "$strawberryPackage"

Write-Output "strawberry = $version" >> ~\versions.txt
