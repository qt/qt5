#############################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
## Copyright (C) 2017 Pelagicore AG
## Contact: http://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL21$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see http://www.qt.io/terms-conditions. For further
## information use the contact form at http://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 2.1 or version 3 as published by the Free
## Software Foundation and appearing in the file LICENSE.LGPLv21 and
## LICENSE.LGPLv3 included in the packaging of this file. Please review the
## following information to ensure the GNU Lesser General Public License
## requirements will be met: https://www.gnu.org/licenses/lgpl.html and
## http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
##
## As a special exception, The Qt Company gives you certain additional
## rights. These rights are described in The Qt Company LGPL Exception
## version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
##
## $QT_END_LICENSE$
##
#############################################################################

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
    $internalUrl = "http://ci-files01-hki.intra.qt.io/input/windows/python-$version-amd64.exe"
} else {
    $externalUrl = "https://www.python.org/ftp/python/$version/python-$version.exe"
    $internalUrl = "http://ci-files01-hki.intra.qt.io/input/windows/python-$version.exe"
}

Write-Host "Fetching from URL..."
Download $externalUrl $internalUrl $package
Verify-Checksum $package $sha1
Write-Host "Installing $package..."
Run-Executable "$package" "/q TargetDir=$install_path"
Write-Host "Remove $package..."
Remove-Item -Path $package

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

Run-Executable "$install_path\Scripts\pip3.exe" "$pip_args install virtualenv wheel"

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

