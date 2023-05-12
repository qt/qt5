# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Install mozilla sccache

param(
    [string]$arch="x86_64-pc-windows-msvc",
    [string]$version="0.2.14",
    [string]$sha1="bbdceb59d6fd7b6a3af02fb36f65c8bf324757b0"
)

. "$PSScriptRoot\helpers.ps1"

$basename = "sccache-" + $version + "-" + $arch
$zipfile = $basename + ".tar.gz"
$tempfile = "C:\Windows\Temp\" + $zipfile
$urlCache = "http://ci-files01-hki.ci.qt.io/input/sccache/" + $zipfile
$urlOfficial = "https://github.com/mozilla/sccache/releases/download/" + $version + "/" + $zipfile
$targetFolder = "C:\Program Files\"

Write-Host "Downloading sccache $version..."
Download $urlOfficial $urlCache $tempfile
Verify-Checksum $tempfile $sha1
Write-Host "Extracting $tempfile to $targetFolder..."
Extract-tar_gz $tempfile $targetFolder
Remove-Item -Path $tempfile

# Turnoff idle timeout to avoid sccache shutting down
Set-EnvironmentVariable "SCCACHE_IDLE_TIMEOUT" "0"

# add sccache to PATH
Set-EnvironmentVariable "PATH" "C:\Program Files\$basename\;$([Environment]::GetEnvironmentVariable('PATH', 'Machine'))"

# update versions
Write-Output "sccache = $version" >> ~\versions.txt
