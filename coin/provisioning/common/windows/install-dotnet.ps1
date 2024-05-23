# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
. "$PSScriptRoot\helpers.ps1"

# This script will install Dotnet SDK which is required for Azure installation

$version = "8.0.300"
$cpu_arch = Get-CpuArchitecture
switch ($cpu_arch) {
    arm64 {
        $sha1 = "3e68f606b205beeb0a557dad5b01e31d4d833459"
        $urlCache = "http://ci-files01-hki.ci.qt.io/input/windows/dotnet-sdk-$version-win-arm64.exe"
        $urlOfficial = "https://download.visualstudio.microsoft.com/download/pr/e195e4f5-00ee-4df3-8736-199aacf00b2a/1663c4f5dc168d390aa4507f09200423/dotnet-sdk-$version-win-arm64.exe"
        Break
    }
    x64 {
        $urlCache = "http://ci-files01-hki.ci.qt.io/input/windows/dotnet-sdk-$version-win-x64.exe"
        $urlOfficial = "https://download.visualstudio.microsoft.com/download/pr/90486d8a-fb5a-41be-bfe4-ad292c06153f/6673965085e00f5b305bbaa0b931cc96/dotnet-sdk-$version-win-x64.exe"
        $sha1 = "527321c1eeea964a7c50f6a24473f37400514cd1"
        Break
    }
    x86 {
        $urlCache = "http://ci-files01-hki.ci.qt.io/input/windows/dotnet-sdk-$version-win-x86.exe"
        $urlOfficial = "https://download.visualstudio.microsoft.com/download/pr/9736c2dc-c21d-4df6-8cb7-9365ed5461a9/4c360dc61c7cb6d26b48d2718341c68e/dotnet-sdk-$version-win-x86.exe"
        $sha1 = "f8857b5e06de5c33aee2fb2242f7781f1a65c4ef"
        Break
    }
    default {
        throw "Unknown architecture $cpu_arch"
    }
}
$installer = "C:\Windows\Temp\dotnet-sdk-$version.exe"

Write-Host "Installing Dotnet SDK $version"
Download $urlOfficial $urlCache $installer
Verify-Checksum $installer $sha1
Run-Executable "$installer" "/install /passive"
Prepend-Path "C:\Program Files\dotnet"
Remove $installer

Write-Output "Dotnet SDK = $version" >> ~/versions.txt



