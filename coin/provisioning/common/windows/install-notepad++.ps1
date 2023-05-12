# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install Notepad++

$version = "7.3"
if (Is64BitWinHost) {
    $arch = ".x64"
    $sha1 = "E7306DF1D6E81801FB4BE0868610DB70E979B0AA"
} else {
    $arch = ""
    $sha1 = "d4c403675a21cc381f640b92e596bae3ef958dc6"
}
$url_cache = "\\ci-files01-hki.intra.qt.io\provisioning\windows\npp." + $version + ".Installer" + $arch + ".exe"
$url_official = "https://notepad-plus-plus.org/repository/7.x/" + $version + "/npp." + $version + ".Installer" + $arch + ".exe"
$nppPackage = "C:\Windows\Temp\npp-$version.exe"

Download $url_official $url_cache $nppPackage
Verify-Checksum $nppPackage $sha1
Run-Executable "$nppPackage" "/S"

Write-Host "Cleaning $nppPackage.."
Remove "$nppPackage"

Write-Output "Notepad++ = $version" >> ~\versions.txt

Write-Host "Disabling auto updates."
Rename-Item -Path "C:\Program Files\Notepad++\updater" -NewName "updater_disabled"
