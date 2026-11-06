# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
. "$PSScriptRoot\helpers.ps1"

# Install Git

$version = "2.56.0.3"
if (Is64BitWinHost) {
    $arch = "-64-bit"
    $checksum = "dc6d3db061999136e139f31376c5582a9ed6f36a4ea12f15e54ad7fa2bfc0bf2"
    $release = "2.56.0.windows.3"
} else {
    $version = "2.36.1"
    $arch = "-32-bit"
    $checksum = "1bbe040254c236607ccb84e14a3f608b1a4e959a"
    $release = "2.36.1.windows.1"
}
$gitPackage = "C:\Windows\Temp\Git-" + $version + $arch + ".exe"
$url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\Git-" + $version + $arch + ".exe"
$url_official = "https://github.com/git-for-windows/git/releases/download/v" + $release + "/Git-" + $version + $arch + ".exe"

Write-Host "Fetching Git $version..."
Download $url_official $url_cache $gitPackage
Verify-Checksum $gitPackage $checksum
Write-Host "Installing Git $version..."
Run-Executable "$gitPackage" "/SILENT /COMPONENTS=`"icons,ext\reg\shellhere,assoc,assoc_sh`""
Write-Host "Adding SSH and SCP to environment variables for RTA"
Set-EnvironmentVariable "SSH" "C:\Program Files\Git\usr\bin\ssh.exe"
Set-EnvironmentVariable "SCP" "C:\Program Files\Git\usr\bin\scp.exe"

Write-Output "Git = $version" >> ~\versions.txt
