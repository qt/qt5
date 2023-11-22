# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
. "$PSScriptRoot\helpers.ps1"

# This script will install vcpkg

Write-Host "Installing vcpkg"

$n = Get-Content "$PSScriptRoot\..\shared\vcpkg_version.txt"
$n = $n.Split('=')
$vcpkgVersion = $n[1]
$nonDottedVersion = $vcpkgVersion.Replace(".", "")

# Download vcpkg
$vcpkgRoot = "C:\Utils\vcpkg-$vcpkgVersion"
$vcpkgRepo = Get-Content -Path "$PSScriptRoot\..\shared\vcpkg_registry_mirror.txt" | Select-Object -First 1

Write-Host "Cloning the vcpkg repo"
git.exe clone "$vcpkgRepo" "$vcpkgRoot"
git.exe -C "$vcpkgRoot" checkout "tags/$vcpkgVersion"

# Download vcpkg-tool, i.e., vcpkg.exe

$n = Get-Content "$PSScriptRoot\..\shared\vcpkg_tool_release_tag.txt"
$n = $n.Split('=')
$vcpkgExeReleaseTag = $n[1]
$nonDottedReleaseTag = $vcpkgExeReleaseTag.replace('-', "")

$vcpkgExeOfficialUrl = "https://github.com/microsoft/vcpkg-tool/releases/download/$vcpkgExeReleaseTag/vcpkg.exe"
$vcpkgExeCacheUrl = "\\ci-files01-hki.ci.qt.io\provisioning\vcpkg\vcpkg-$nonDottedReleaseTag-windows-x64.exe"
$vcpkgExeSHA1 = "F74DCDE7F6F5082EF6DC31FED486FAD69BE8D442"
$vcpkgExe = "C:\Windows\Temp\vcpkg.exe"

Download "$vcpkgExeOfficialUrl" "$vcpkgExeCacheUrl" "$vcpkgExe"
Verify-Checksum $vcpkgExe $vcpkgExeSHA1
Move-Item "$vcpkgExe" -Destination "$vcpkgRoot" -Force

if(![System.IO.File]::Exists("$vcpkgRoot\vcpkg.exe")){
    Write-Host "Can't find $vcpkgRoot\vcpkg.exe."
    exit 1
}

# Disable telemetry
Set-Content -Value "" -Path "$vcpkgRoot\vcpkg.disable-metrics" -Force

# Setting VCPKG_ROOT using Set-EnvironmentVariable makes the variable only
# available during build time. In order to make it available during the
# provisioning, we need to directly set it via $env:VCPKG_ROOT as well.
Set-EnvironmentVariable "VCPKG_ROOT" "$vcpkgRoot"
$env:VCPKG_ROOT = "$vcpkgRoot"

# Set a source for vcpkg Binary and Asset Cache
# The `coin/provisioning/common/windows/mount-vcpkg-cache-drive.ps1` script is
# mounting the SMB share located in `vcpkg-server.ci.qt.io/vcpkg` to drive V:\
$env:VCPKG_BINARY_SOURCES = "files,V:/binaries,readwrite"
$env:X_VCPKG_ASSET_SOURCES = "x-azurl,file:///V:/assets,,readwrite"

Write-Output "vcpkg = $vcpkgVersion" >> ~/versions.txt
