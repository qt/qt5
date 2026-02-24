# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
. "$PSScriptRoot\helpers.ps1"

# Install Openssh

$version = "v9.2.2.0p1-Beta"

$temp = "$env:tmp"
$cpu_arch = Get-CpuArchitecture
switch ($cpu_arch) {
    arm64 {
        $base_file_name = "OpenSSH-ARM64"
        $sha1 = "ca3e8f44a550b7ae71c8e122acd4ed905d66feb0"
        Break
    }
    x64 {
        $base_file_name = "OpenSSH-Win64"
        $sha1 = "1397d40d789ae0911b3cc818b9dcd9321fed529b"
        Break
    }
    x86 {
        $base_file_name = "OpenSSH-Win32"
        $sha1 = "4642C62F72C108C411E27CE282A863791B63329B"
        Break
    }
    default {
        throw "Unknown architecture $cpu_arch"
    }
}

Write-Host "Fetching $base_file_name $version..."
$url_cache = "http://ci-files01-hki.ci.qt.io/input/windows/openssh/$version/$base_file_name.zip"
$url_official = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/$version/$base_file_name.zip"
$output_zip_file = "$temp\$base_file_name.zip"
Download $url_official $url_cache $output_zip_file
Verify-Checksum $output_zip_file $sha1

Write-Host "Extracting the package"
Extract-7Zip $output_zip_file "C:\Program Files"
# We assume the incoming zip contains exactly one directory, named the same
# as the base file name of th zip.
$output_dir = "C:\Program Files\$base_file_name"
if (-not (Test-Path $output_dir -PathType Container)) {
    throw "Error. Expected output directory '$output_dir' does not exist."
}

Write-Host "Installing $base_file_name $version..."
$install_script = "$output_dir\install-sshd.ps1"

# Installation done as shown at https://github.com/PowerShell/Win32-OpenSSH/wiki/Install-Win32-OpenSSH
powershell.exe -ExecutionPolicy Bypass -File $install_script
netsh advfirewall firewall add rule name=sshd dir=in action=allow protocol=TCP localport=22
net start sshd
Set-Service sshd -StartupType Automatic
