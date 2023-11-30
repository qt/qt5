# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
. "$PSScriptRoot\helpers.ps1"

Write-Host "Installing vcpkg android ports"
$vcpkgExe = "$env:VCPKG_ROOT\vcpkg.exe"
$vcpkgRoot = "$env:VCPKG_ROOT"

Set-Location -Path "$PSScriptRoot\vcpkg"
Copy-Item "$PSScriptRoot\..\shared\vcpkg-configuration.json" -Destination "$PSScriptRoot\vcpkg"

Run-Executable "$vcpkgExe" "install --triplet armeabi-v7a-android-qt --x-install-root armeabi-v7a-android-qt-tmp --debug"

New-Item -Path "$vcpkgRoot" -Name "installed" -ItemType "directory" -Force
Copy-Item -Path "armeabi-v7a-android-qt-tmp\*" -Destination "$vcpkgRoot\installed" -Recurse -Force

$versions = jq.exe -r '.overrides[] | \"vcpkg \(.name) for android = \(.version)\"' vcpkg.json
$versions = $versions.Replace("vcpkg", "`nvcpkg")
Write-Output "$versions" >> ~/versions.txt

Remove-Item -Path "armeabi-v7a-android-qt-tmp" -Recurse -Force

Set-Location "$PSScriptRoot"
