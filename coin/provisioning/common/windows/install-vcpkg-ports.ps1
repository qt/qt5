# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
. "$PSScriptRoot\helpers.ps1"

Write-Host "Installing vcpkg ports"
$vcpkgExe = "$env:VCPKG_ROOT\vcpkg.exe"
$vcpkgRoot = "$env:VCPKG_ROOT"

Set-Location -Path "$PSScriptRoot\vcpkg"
Copy-Item "$PSScriptRoot\..\shared\vcpkg-configuration.json" -Destination "$PSScriptRoot\vcpkg"

Run-Executable "$vcpkgExe" "install --triplet x64-windows-qt --x-install-root x64-windows-qt-tmp --debug"
Run-Executable "$vcpkgExe" "install --triplet arm64-windows-qt --x-install-root arm64-windows-qt-tmp --debug"

New-Item -Path "$vcpkgRoot" -Name "installed" -ItemType "directory" -Force
Copy-Item -Path "x64-windows-qt-tmp\*" -Destination "$vcpkgRoot\installed" -Recurse -Force
Copy-Item -Path "arm64-windows-qt-tmp\*" -Destination "$vcpkgRoot\installed" -Recurse -Force

$versions = jq.exe -r '.overrides[] | \"vcpkg \(.name) = \(.version)\"' vcpkg.json
$versions = $versions.Replace("vcpkg", "`nvcpkg")
Write-Output "$versions" >> ~/versions.txt

Remove-Item -Path "x64-windows-qt-tmp" -Recurse -Force
Remove-Item -Path "arm64-windows-qt-tmp" -Recurse -Force

Set-Location "$PSScriptRoot"
