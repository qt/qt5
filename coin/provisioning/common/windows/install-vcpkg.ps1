# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
param([string]$arch="x64")

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

$releaseTagFileContent = Get-Content "$PSScriptRoot\..\shared\vcpkg_tool_release_tag.txt"
$n = $releaseTagFileContent.Split("`n")
$sha1key = "windows_" + $arch + "_sha1"
foreach ($keyValue in $n) {
    $keyValue = $keyValue.Split('=')
    if($keyValue[0] -eq "vcpkg_tool_release_tag") {
        $vcpkgExeReleaseTag = $keyValue[1]
    } elseif($keyValue[0] -eq $sha1key) {
        $vcpkgExeSHA1 = $keyValue[1]
    }
}

if(!$vcpkgExeReleaseTag) {
    Write-Host "Unable to read release tag from $PSScriptRoot\..\shared\vcpkg_tool_release_tag.txt"
    Write-Host "Content:"
    Write-Host "$releaseTagFileContent"
    exit 1
}
$nonDottedReleaseTag = $vcpkgExeReleaseTag.replace('-', "")

if(!$vcpkgExeSHA1) {
    Write-Host "Unable to read vcpkg tool SHA1 from $PSScriptRoot\..\shared\vcpkg_tool_release_tag.txt"
    Write-Host "Content:"
    Write-Host "$releaseTagFileContent"
    exit 1
}

$suffix = "-$arch"
if($arch -eq "x64") {
    $suffix = ""
}

$vcpkgExeOfficialUrl = "https://github.com/microsoft/vcpkg-tool/releases/download/$vcpkgExeReleaseTag/vcpkg$suffix.exe"
$vcpkgExeCacheUrl = "\\ci-files01-hki.ci.qt.io\provisioning\vcpkg\vcpkg-$nonDottedReleaseTag-windows-$arch.exe"
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

# Bootstrap vcpkg
Set-Location -Path "$vcpkgRoot"
cmd.exe /c "$vcpkgRoot\bootstrap-vcpkg.bat"

Set-EnvironmentVariable "VCPKG_ROOT" "$vcpkgRoot"

# Set a source for vcpkg Binary and Asset Cache
# The `coin/provisioning/common/windows/mount-vcpkg-cache-drive.ps1` script is
# mounting the SMB share located in `vcpkg-server.ci.qt.io/vcpkg` to drive V:\
$env:VCPKG_BINARY_SOURCES = "files,V:/binaries,readwrite"
$env:X_VCPKG_ASSET_SOURCES = "x-azurl,file:///V:/assets,,readwrite"

Set-EnvironmentVariable "VCPKG_BINARY_SOURCES" $env:VCPKG_BINARY_SOURCES
Set-EnvironmentVariable "X_VCPKG_ASSET_SOURCES" $env:X_VCPKG_ASSET_SOURCES

Write-Output "vcpkg = $vcpkgVersion" >> ~/versions.txt
