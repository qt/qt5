#############################################################################
##
## Copyright (C) 2016 The Qt Company Ltd.
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

. "$PSScriptRoot\helpers.ps1"

# This script installs Python $version.
# Python is required for building Qt 5 from source.

$version = "2.7.10"
$package = "C:\Windows\temp\python-$version.msi"

# check bit version
if ([System.Environment]::Is64BitProcess -eq $TRUE) {
    $externalUrl = "https://www.python.org/ftp/python/$version/python-$version.amd64.msi"
    $internalUrl = "http://ci-files01-hki.ci.local/input/windows/python-$version.amd64.msi"
    $sha1 = "f3a474f6ab191f9b43034c0fb5c98301553775d4"
}
else {
    $externalUrl = "https://www.python.org/ftp/python/$version/python-$version.msi"
    $internalUrl = "http://ci-files01-hki.ci.local/input/windows/python-$version.msi"
    $sha1 = "9e62f37407e6964ee0374b32869b7b4ab050d12a"
}

echo "Fetching from URL..."
Download $externalUrl $internalUrl $package
Verify-Checksum $package $sha1
echo "Installing $package..."
cmd /c "$package /q"
# We need to change allowZip64 from 'False' to 'True' to be able to create ZIP files that use the ZIP64 extensions when the zipfile is larger than 2 GB
echo "Chancing allowZip64 value to 'True'..."
(Get-Content C:\Python27\lib\zipfile.py) | ForEach-Object { $_ -replace "allowZip64=False", "allowZip64=True" } | Set-Content C:\Python27\lib\zipfile.py
echo "Remove $package..."
del $package
Add-Path $path

& python -m ensurepip
# Install python virtual env
pip.exe install virtualenv
