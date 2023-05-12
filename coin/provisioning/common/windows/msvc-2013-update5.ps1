# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
. "$PSScriptRoot\helpers.ps1"

# Install Visual Studio 2013 update 5

$version = "2013 Update 5 (KB2829760)"
$package = "C:\Windows\Temp\vs12-kb2829760.exe"
$url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\VS2013.5.exe"

Write-Host "Fetching patch for Visual Studio $version..."
Copy-Item $url_cache $package

Write-Host "Installing Update 5 for Visual Studio $version..."
Run-Executable "$package" "/norestart /passive"

Write-Host "Removing $package ..."
Remove "$package"

Write-Output "Visual Studio = $version" >> ~\versions.txt
