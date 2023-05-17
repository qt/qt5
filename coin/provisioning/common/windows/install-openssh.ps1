#############################################################################
##
## Copyright (C) 2022 The Qt Company Ltd.
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
. "$PSScriptRoot\helpers.ps1"

# Install Openssh

$version = "v9.2.2.0p1-Beta"

$temp = "$env:tmp"
if (Is64BitWinHost) {
    $zipPackage = "OpenSSH-Win64"
    $url_cache = "http://ci-files01-hki.ci.qt.io/input/windows/" + $zipPackage + ".zip"
    $url_official = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/" + $version + "/" + $zipPackage
    $sha1 = "D3EA57408C0D3CF83167DF39639FED5397358B79"
} else {
    $zipPackage = "OpenSSH-Win32"
    $url_cache = "http://ci-files01-hki.ci.qt.io/input/windows/openssh/" + $version + "/" + $zipPackage + ".zip"
    $url_official = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/" + $version + "/" + $zipPackage
    $sha1 = "4642C62F72C108C411E27CE282A863791B63329B"
}

Write-Host "Fetching $zipPackage $version..."
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
