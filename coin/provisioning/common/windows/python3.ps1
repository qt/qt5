# Copyright (C) 2019 The Qt Company Ltd.
# Copyright (C) 2017 Pelagicore AG
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs Python $version.
# Python3 is required for building some qt modules.
param(
    [Int32]$archVer,
    [string]$sha1,
    [string]$install_path,
    [string]$version,
    [bool]$setDefault=$false
)
. "$PSScriptRoot\helpers.ps1"

$package = "C:\Windows\temp\python-$version.exe"

# check bit version
$cpu_arch = Get-CpuArchitecture
Write-Host "Installing $cpu_arch Python"
switch ($cpu_arch) {
    arm64 {
        $externalUrl = "https://www.python.org/ftp/python/$version/python-$version-arm64.exe"
        $internalUrl = "http://ci-files01-hki.ci.qt.io/input/windows/python-$version-arm64.exe"
        Break
    }
    x64 {
        if ($archVer -eq "64") {
            $externalUrl = "https://www.python.org/ftp/python/$version/python-$version-amd64.exe"
            $internalUrl = "http://ci-files01-hki.ci.qt.io/input/windows/python-$version-amd64.exe"
        } else {
            $externalUrl = "https://www.python.org/ftp/python/$version/python-$version.exe"
            $internalUrl = "http://ci-files01-hki.ci.qt.io/input/windows/python-$version.exe"
        }
    }
    default {
        throw "Unknown architecture $cpu_arch"
    }
}

Write-Host "Fetching from URL..."
Download $externalUrl $internalUrl $package
Verify-Checksum $package $sha1
Write-Host "Installing $package..."
Run-Executable "$package" "/q TargetDir=$install_path"
Remove "$package"

# For cross-compilation we export some helper env variable
if (($archVer -eq 32) -And (Is64BitWinHost)) {
    if ($setDefault) {
        Set-EnvironmentVariable "PYTHON3_32_PATH" "$install_path"
        Set-EnvironmentVariable "PIP3_32_PATH" "$install_path\Scripts"
    }
    Set-EnvironmentVariable "PYTHON$version-32_PATH" "$install_path"
    Set-EnvironmentVariable "PIP$version-32_PATH" "$install_path\Scripts"
} else {
    if ($setDefault) {
        Set-EnvironmentVariable "PYTHON3_PATH" "$install_path"
        Set-EnvironmentVariable "PIP3_PATH" "$install_path\Scripts"
    }
    Set-EnvironmentVariable "PYTHON$version-64_PATH" "$install_path"
    Set-EnvironmentVariable "PIP$version-64_PATH" "$install_path\Scripts"
}


# Install python virtual env
if (IsProxyEnabled) {
    $proxy = Get-Proxy
    Write-Host "Using proxy ($proxy) with pip"
    $pip_args = "--proxy=$proxy"
}

Write-Host "Upgrade pip3 to the latest version available."
Run-Executable "$install_path\python.exe" "-m pip install --upgrade pip"

Write-Host "Configure pip"
Run-Executable "$install_path\python.exe" "-m pip config --user set global.index https://ci-files01-hki.ci.qt.io/input/python_module_cache"
Run-Executable "$install_path\python.exe" "-m pip config --user set global.extra-index-url https://pypi.org/simple/"
Run-Executable "$install_path\Scripts\pip3.exe" "$pip_args install virtualenv wheel html5lib"

# Check if python version is higher than 3.10.
# ntia-conformance-checker requires at least 3.8
# reuse requires at least 3.9, to avoid conflict with installed conan jinja package,
# at least until we use virtual envs.
# The lowest version available on all windows platforms that we currently run on that satisfies
# these requirements is 3.10.
if ([version]::Parse($version) -gt [version]::Parse("3.10")) {
    Run-Executable "$install_path\Scripts\pip3.exe" "$pip_args install -r $PSScriptRoot\..\shared\requirements.txt"
    # Set the environment variable for the build system to know which python path to use for SBOM
    # processing.
    Set-EnvironmentVariable "SBOM_PYTHON_APPS_PATH" "$install_path\Scripts"
    Set-EnvironmentVariable "SBOM_PYTHON_INTERP_PATH" "$install_path\python.exe"
}

# Install PyPDF2 for QSR documentation
Run-Executable "$install_path\Scripts\pip3.exe" "$pip_args install PyPDF2"

Write-Output "Python3-$archVer = $version" >> ~/versions.txt

