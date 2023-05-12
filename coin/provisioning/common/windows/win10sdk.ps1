# Copyright (C) 2018 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install Windows 10 SDK

$url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\winsdksetup.exe"
$url_official = "https://download.microsoft.com/download/8/C/3/8C37C5CE-C6B9-4CC8-8B5F-149A9C976035/windowssdk/winsdksetup.exe"
$package = "C:\Windows\Temp\winsdksetup.exe"
$sha1 = "db237323f1779fb143e7cdc558e4345e7004489e"

Copy-Item $url_cache $package
Verify-Checksum $package $sha1
Run-Executable $package "/features + /q"

Write-Host "Cleaning $package.."
Remove "$package"

Write-Output "Windows 10 SDK = 10.0.16229.91" >> ~\versions.txt
