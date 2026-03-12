# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Install mozilla sccache


. "$PSScriptRoot\helpers.ps1"

$version="v0.15.0"
$cpu_arch = Get-CpuArchitecture
switch ($cpu_arch) {
    arm64 {
        $arch="aarch64-pc-windows-msvc"
        $sha="f4f304dc9dd9bd2f9b0032a0091efac1c093934bb095f207381558f80c3d0a24"
        break
    }
    x64 {
        $arch="x86_64-pc-windows-msvc"
        $sha="b0b257a164bf438b2dea134ca7ded41c100f59a64b3bf275a202f1e8102ab217"
        break
    }
    x86 {
        $arch="x86-pc-windows-gnu"
        $sha="287f4c3b7db21b72138704b8fe96827e6b1643a8"
        $version="0.2.13-alpha-0"
        break
    }

    default {
        throw "Unknown architecture $cpu_arch"
    }
}

$basename = "sccache-" + $version + "-" + $arch
$zipfile = $basename + ".tar.gz"
$tempfile = "C:\Windows\Temp\" + $zipfile
$urlCache = "http://ci-files01-hki.ci.qt.io/input/sccache/" + $zipfile
$urlOfficial = "https://github.com/mozilla/sccache/releases/download/" + $version + "/" + $zipfile
$targetFolder = "C:\Program Files\"

Write-Host "Downloading sccache $version..."
Download $urlOfficial $urlCache $tempfile
Verify-Checksum $tempfile $sha
Write-Host "Extracting $tempfile to $targetFolder..."
Extract-tar_gz $tempfile $targetFolder
Remove-Item -Path $tempfile

# Turnoff idle timeout to avoid sccache shutting down
Set-EnvironmentVariable "SCCACHE_IDLE_TIMEOUT" "0"

# Prevents build job dying from random network I/O errors
Set-EnvironmentVariable "SCCACHE_IGNORE_SERVER_IO_ERROR" "1"

# add sccache to PATH
Set-EnvironmentVariable "PATH" "C:\Program Files\$basename\;$([Environment]::GetEnvironmentVariable('PATH', 'Machine'))"
# Enable a local preprocessor cache.
Set-EnvironmentVariable "SCCACHE_DIRECT" "1"

# update versions
Write-Output "sccache = $version" >> ~\versions.txt
