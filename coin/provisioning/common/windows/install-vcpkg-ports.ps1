# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

param([string]$arch="x64")

. "$PSScriptRoot\helpers.ps1"

Write-Host "Installing vcpkg ports"
$vcpkgExe = "$env:VCPKG_ROOT\vcpkg.exe"
$vcpkgRoot = "$env:VCPKG_ROOT"
$vcpkgInstallRoot = "$arch-windows-qt-tmp"

Set-Location -Path "$PSScriptRoot\..\shared\vcpkg"
Run-Executable "$vcpkgExe" "install --triplet $arch-windows-qt --x-install-root $vcpkginstallroot --debug"

New-Item -Path "$vcpkgRoot" -Name "installed" -ItemType "directory" -Force
Copy-Item -Path "$vcpkginstallroot\*" -Destination "$vcpkgRoot\installed" -Recurse -Force

Run-Executable "cmake" "-DVCPKG_EXECUTABLE=$vcpkgExe -DVCPKG_INSTALL_ROOT=$vcpkgInstallRoot -DOUTPUT=$env:USERPROFILE\versions.txt -P $PSScriptRoot\..\shared\vcpkg_parse_packages.cmake"

Set-EnvironmentVariable "VCPKG_INSTALLED_DIR" "$vcpkgRoot\installed"

Remove-Item -Path "$vcpkginstallroot" -Recurse -Force

Set-Location "$PSScriptRoot"
