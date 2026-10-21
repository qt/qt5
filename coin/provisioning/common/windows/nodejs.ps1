# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install Node.js
# Needed by QtWebengine

$version = "24.22.1"
$cpu_arch = Get-CpuArchitecture
switch ($cpu_arch) {
    arm64 {
        $arch = "arm64"
        $sha256 = "aa26929d4ca7754aac3bd7fd018eb5c1c7961d00adf8aebf35c435d66edef62e"
        Break
    }
    x64 {
        $arch = "x64"
        $sha256 = "bf9245db3a3bb281da45fee3974a74403687ea6030587bee4fd992efc822c35c"
        Break
    }
    default {
        throw "Unknown architecture $cpu_arch"
    }
}

$package = "C:\Windows\temp\nodejs-$version.7z"
$targetFolder = "C:\Utils"
$installFolder = "C:\Utils\node-v$version-win-$arch"
$externalUrl = "https://nodejs.org/dist/v$version/node-v$version-win-$arch.7z"
$internalUrl = "http://ci-files01-hki.ci.qt.io/input/windows/node-v$version-win-$arch.7z"

Write-Host "Installing Node.js"
Download $externalUrl $internalUrl $package
Verify-Checksum $package $sha256
Extract-7Zip $package $targetFolder
Add-Path $installFolder
Remove $package

Write-Output "Node.js = $version" >> ~/versions.txt
