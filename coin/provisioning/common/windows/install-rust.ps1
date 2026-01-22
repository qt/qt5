# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install Rust

$rust_version="1.92.0"

$cpu_arch = Get-CpuArchitecture
switch ($cpu_arch) {
    arm64 {
        $rust_arch = "aarch64"
        $sha256="DBB09F213D5A9EBB3B2F4C7D65BA7C3C6CAD7D9A76927D079604020C3EA0AD5A"
        Break
    }
    x64 {
        $rust_arch = "x86_64"
        $sha256="BD3FD270E92D12094151AAE3A67435B7FEF2164B10D96E99A94230929CDA09FD"
        Break
    }
    default {
        throw "Unknown architecture $cpu_arch"
    }
}

$installer_name="rust-" + $rust_version + "-" + $rust_arch + "-pc-windows-msvc.msi"

$url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\" + $installer_name
$url_official = "https://static.rust-lang.org/dist/" + $installer_name
$tmp_package = "C:\Windows\Temp\" + $installer_name

Download $url_official $url_cache $tmp_package
Verify-Checksum $tmp_package $sha256 "sha256"
Run-Executable "msiexec" "/quiet /i $tmp_package"

Set-EnvironmentVariable "PATH" "C:\Program Files\Rust stable MSVC 1.92\bin;$([Environment]::GetEnvironmentVariable('PATH', 'Machine'))"

Run-Executable "cargo" "install bindgen-cli --root=C:\Utils\rust-tools"

Set-EnvironmentVariable "PATH" "C:\Utils\rust-tools\bin;$([Environment]::GetEnvironmentVariable('PATH', 'Machine'))"

Write-Host "Cleaning $tmp_package.."
Remove "$tmp_package"

Write-Output "Rust = $version" >> ~\versions.txt
