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
if ( $archVer -eq 64 ) {
    Write-Host "Installing 64 bit Python"
    $externalUrl = "https://www.python.org/ftp/python/$version/python-$version-amd64.exe"
    $internalUrl = "http://ci-files01-hki.ci.qt.io/input/windows/python-$version-amd64.exe"
} else {
    $externalUrl = "https://www.python.org/ftp/python/$version/python-$version.exe"
    $internalUrl = "http://ci-files01-hki.ci.qt.io/input/windows/python-$version.exe"
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

Run-Executable "$install_path\Scripts\pip3.exe" "$pip_args install virtualenv wheel html5lib"

# Install all needed packages in a special wheel cache directory
$python3_wheel_dir="$install_path\python3-wheels"
Run-Executable "$install_path\Scripts\pip3.exe" "$pip_args wheel --wheel-dir $python3_wheel_dir -r $PSScriptRoot\..\shared\requirements.txt"

Set-EnvironmentVariable "PYTHON3_WHEEL_CACHE-$version-$archVer" "$python3_wheel_dir"
# PYTHON3_WHEEL_CACHE is already in use so we should keep it pointing to 64 bit default
# wheel cache
if (($setDefault) -And ($archVer -eq 64)) {
    Set-EnvironmentVariable "PYTHON3_WHEEL_CACHE" "$python3_wheel_dir"
}

# Install PyPDF2 for QSR documentation
Run-Executable "$install_path\Scripts\pip3.exe" "$pip_args install PyPDF2"

Write-Output "Python3-$archVer = $version" >> ~/versions.txt

