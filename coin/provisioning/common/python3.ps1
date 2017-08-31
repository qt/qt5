#############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
## Copyright (C) 2017 Pelagicore AG
## Contact: http://www.qt.io/licensing/
##
## This file is part of the test suite of the Qt Toolkit.
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

param([Int32]$archVer=32)
. "$PSScriptRoot\helpers.ps1"

# This script installs Python $version.
# Python3 is required for building some qt modules.

$version = "3.6.1"
$package = "C:\Windows\temp\python-$version.exe"
$install_path = "C:\Python36"

# check bit version
if ( $archVer -eq 64 ) {
    echo "Running in 64 bit system"
    $externalUrl = "https://www.python.org/ftp/python/$version/python-$version-amd64.exe"
    $internalUrl = "http://ci-files01-hki.ci.local/input/windows/python-$version-amd64.exe"
    $sha1 = "bf54252c4065b20f4a111cc39cf5215fb1edccff"
}
else {
    $externalUrl = "https://www.python.org/ftp/python/$version/python-$version.exe"
    $internalUrl = "http://ci-files01-hki.ci.local/input/windows/python-$version.exe"
    $sha1 = "76c50b747237a0974126dd8b32ea036dd77b2ad1"
}

echo "Fetching from URL..."
Download $externalUrl $internalUrl $package
Verify-Checksum $package $sha1
echo "Installing $package..."
cmd /c "$package /q TargetDir=$install_path"
echo "Remove $package..."
del $package

[Environment]::SetEnvironmentVariable("PYTHON3_PATH", "$install_path", [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("PIP3_PATH", "$install_path\Scripts", [EnvironmentVariableTarget]::Machine)

# Install python virtual env
cmd /c "$install_path\Scripts\pip3.exe install virtualenv"
