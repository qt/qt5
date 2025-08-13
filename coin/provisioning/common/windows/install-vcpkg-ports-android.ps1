# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
. "$PSScriptRoot\helpers.ps1"

Write-Host "Installing vcpkg android ports"
$vcpkgExe = "$env:VCPKG_ROOT\vcpkg.exe"
$vcpkgRoot = "$env:VCPKG_ROOT"
$vcpkgInstallRoot = "armeabi-v7a-android-qt-tmp"

Set-Location -Path "$PSScriptRoot\..\shared\vcpkg"
Run-Executable "$vcpkgExe" "install --triplet armeabi-v7a-android-qt --x-install-root $vcpkgInstallRoot --debug"

New-Item -Path "$vcpkgRoot" -Name "installed" -ItemType "directory" -Force
Copy-Item -Path "$vcpkgInstallRoot\*" -Destination "$vcpkgRoot\installed" -Recurse -Force

Run-Executable "cmake" "-DVCPKG_EXECUTABLE=$vcpkgExe -DVCPKG_INSTALL_ROOT=$vcpkgInstallRoot -DOUTPUT=$env:USERPROFILE\versions.txt -P $PSScriptRoot\..\shared\vcpkg_parse_packages.cmake"

Remove-Item -Path "$vcpkgInstallRoot" -Recurse -Force

Set-Location "$PSScriptRoot"
