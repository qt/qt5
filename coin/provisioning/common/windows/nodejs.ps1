# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install Node.js
# Needed by QtWebengine

$version = "20.7.0"
$cpu_arch = Get-CpuArchitecture
switch ($cpu_arch) {
    arm64 {
        $arch = "arm64"
        $sha256 = "ab4b990c2c1d4a55d565813e7a2f71669dc4d1005faa47185d30bde4416975ab"
        $version = "20.12.2" # TODO: ARM starts with newer, LTS
        Break
    }
    x64 {
        $arch = "x64"
        $sha256 = "b3e5cbf8e247c75f9ddd235d49cfe40f25dde65bdd0eec4cefbca2805d80376b"
        Break
    }
    x86 {
        $arch = "x86"
        $sha256 = "d6a3c63a5ae71374c144a33c418ab96be497b08df0e9f51861a78127db03aeb5"
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
Verify-Checksum $package $sha256 "sha256"
Extract-7Zip $package $targetFolder
Add-Path $installFolder
Remove $package

Write-Output "Node.js = $version" >> ~/versions.txt
