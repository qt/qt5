# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
. "$PSScriptRoot\helpers.ps1"

# Install Openssh

$version = "v9.2.2.0p1-Beta"

$temp = "$env:tmp"
$cpu_arch = Get-CpuArchitecture
switch ($cpu_arch) {
    arm64 {
        $zipPackage = "OpenSSH-ARM64"
        $sha1 = "ca3e8f44a550b7ae71c8e122acd4ed905d66feb0"
        Break
    }
    x64 {
        $zipPackage = "OpenSSH-Win64"
        $sha1 = "1397d40d789ae0911b3cc818b9dcd9321fed529b"
        Break
    }
    x86 {
        $zipPackage = "OpenSSH-Win32"
        $sha1 = "4642C62F72C108C411E27CE282A863791B63329B"
        Break
    }
    default {
        throw "Unknown architecture $cpu_arch"
    }
}

Write-Host "Fetching $zipPackage $version..."
$url_cache = "http://ci-files01-hki.ci.qt.io/input/windows/openssh/" + $version + "/" + $zipPackage + ".zip"
$url_official = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/" + $version + "/" + $zipPackage + ".zip"
Download $url_official $url_cache "$temp\$zipPackage"
Verify-Checksum "$temp\$zipPackage" $sha1

Write-Host "Extracting the package"
Extract-7Zip "$temp\$zipPackage" C:\"Program Files"

Write-Host "Installing $zipPackage $version..."
$path = "C:\Program Files\" + $zipPackage + "\install-sshd.ps1"

# Installation done as shown at https://github.com/PowerShell/Win32-OpenSSH/wiki/Install-Win32-OpenSSH
powershell.exe -ExecutionPolicy Bypass -File $path
netsh advfirewall firewall add rule name=sshd dir=in action=allow protocol=TCP localport=22
net start sshd
Set-Service sshd -StartupType Automatic
