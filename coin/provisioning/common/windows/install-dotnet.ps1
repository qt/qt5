# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
. "$PSScriptRoot\helpers.ps1"

# This script will install Dotnet SDK which is required for Azure installation

$version = "2.1"
if (Is64BitWinHost) {
    $urlCache = "http://ci-files01-hki.ci.qt.io/input/windows/dotnet-sdk-2.1.809-win-x64.exe"
    $urlOfficial = "https://download.visualstudio.microsoft.com/download/pr/c980b6fb-e570-4c73-b344-e4dae6573777/f844ac1a4c6ea5de7227a701786126fd/dotnet-sdk-2.1.809-win-x64.exe"
    $sha1 = "343e80c2ab558a30696dbe03ad2288bf435d5cd8"
} else {
    $urlCache = "http://ci-files01-hki.ci.qt.io/input/windows/dotnet-sdk-2.1.809-win-x86.exe"
    $urlOfficial = "https://download.visualstudio.microsoft.com/download/pr/cf86a2f3-f6b2-4959-8e41-cf84b0d2f294/a61e834f56abe2dc2e12599e1a60c10b/dotnet-sdk-2.1.809-win-x86.exe"
    $sha1 = "b38a4e1392f17aed110508a1687f1c65b9d86161"
}
$installer = "C:\Windows\Temp\dotnet-sdk-$version.exe"

Write-Host "Installing Dotnet SDK $version"
Download $urlOfficial $urlCache $installer
Verify-Checksum $installer $sha1
Run-Executable "$installer" "/install /passive"
Prepend-Path "C:\Program Files\dotnet"
Remove $installer

Write-Output "Dotnet SDK = $version" >> ~/versions.txt



