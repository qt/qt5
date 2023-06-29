#############################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
## Copyright (C) 2017 Pelagicore AG
## Contact: https://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see https://www.qt.io/terms-conditions. For further
## information use the contact form at https://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 3 as published by the Free Software
## Foundation and appearing in the file LICENSE.LGPL3 included in the
## packaging of this file. Please review the following information to
## ensure the GNU Lesser General Public License version 3 requirements
## will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 2.0 or (at your option) the GNU General
## Public license version 3 or any later version approved by the KDE Free
## Qt Foundation. The licenses are as published by the Free Software
## Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
## included in the packaging of this file. Please review the following
## information to ensure the GNU General Public License requirements will
## be met: https://www.gnu.org/licenses/gpl-2.0.html and
## https://www.gnu.org/licenses/gpl-3.0.html.
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

# Install PyPDF2 for QSR documentation
Run-Executable "$install_path\Scripts\pip3.exe" "$pip_args install PyPDF2"

Write-Output "Python3-$archVer = $version" >> ~/versions.txt

