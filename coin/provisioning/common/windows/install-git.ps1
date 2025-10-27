# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
. "$PSScriptRoot\helpers.ps1"

# Install Git

$version = "2.51.1"
if (Is64BitWinHost) {
    $arch = "-64-bit"
    $sha1 = "831c8968c709af0cbd20a634572b44293db43bec"
} else {
    $version = "2.36.1"
    $arch = "-32-bit"
    $sha1 = "1bbe040254c236607ccb84e14a3f608b1a4e959a"
}
$gitPackage = "C:\Windows\Temp\Git-" + $version + $arch + ".exe"
$url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\Git-" + $version + $arch + ".exe"
$url_official = "https://github.com/git-for-windows/git/releases/download/v" + $version + ".windows.1/Git-" + $version + $arch + ".exe"

Write-Host "Fetching Git $version..."
Download $url_official $url_cache $gitPackage
Verify-Checksum $gitPackage $sha1
Write-Host "Installing Git $version..."
Run-Executable "$gitPackage" "/SILENT /COMPONENTS=`"icons,ext\reg\shellhere,assoc,assoc_sh`""
Write-Host "Adding SSH and SCP to environment variables for RTA"
Set-EnvironmentVariable "SSH" "C:\Program Files\Git\usr\bin\ssh.exe"
Set-EnvironmentVariable "SCP" "C:\Program Files\Git\usr\bin\scp.exe"

Write-Output "Git = $version" >> ~\versions.txt
