# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

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
$url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\rubyinstaller-" + $version + $arch + ".exe"
$url_official = "https://github.com/oneclick/rubyinstaller2/releases/download/rubyinstaller-" + $version + "/rubyinstaller-" + $version + $arch + ".exe"
$rubyPackage = "C:\Windows\Temp\rubyinstaller-$version.exe"

Download $url_official $url_cache $rubyPackage
Verify-Checksum $rubyPackage $sha1
Run-Executable $rubyPackage "/dir=C:\Ruby-$version$arch /tasks=modpath /verysilent"

Write-Host "Cleaning $rubyPackage.."
Remove "$rubyPackage"

Write-Output "Ruby = $version" >> ~\versions.txt
