# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\..\common\windows\helpers.ps1"

# This script will install VirtualBox

$version = "5.2.4"
$sha1 = "71df4474a5e94918728b62d1f6bc036674ef0e96"
$url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\VirtualBox-" + $version + "-119785-Win.exe"
$url_official = "http://download.virtualbox.org/virtualbox/" + $version + "/VirtualBox-" + $version + "-119785-Win.exe"
$virtualboxPackage = "C:\Windows\Temp\virtualbox-$version.exe"

Download $url_official $url_cache $virtualboxPackage
Verify-Checksum $virtualboxPackage $sha1
Run-Executable $virtualboxPackage "--silent"

Write-Output "Cleaning $virtualboxPackage.."
Remove "$virtualboxPackage"

Write-Output "VirtualBox = $version" >> ~\versions.txt
