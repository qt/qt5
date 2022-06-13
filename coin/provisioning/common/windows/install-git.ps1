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

# Install Git

$version = "2.36.1"
if (Is64BitWinHost) {
    $arch = "-64-bit"
    $sha1 = "594bdfc4e7704fb03fe14b7c0613087dfa3d4416"
} else {
    $arch = "-32-bit"
    $sha1 = "1bbe040254c236607ccb84e14a3f608b1a4e959a"
}
$gitPackage = "C:\Windows\Temp\Git-" + $version + $arch + ".exe"
$url_cache = "\\ci-files01-hki.intra.qt.io\provisioning\windows\Git-" + $version + $arch + ".exe"
$url_official = "https://github.com/git-for-windows/git/releases/download/v" + $version + ".windows.1/Git-" + $version + $arch + ".exe"

Write-Host "Fetching Git $version..."
Download $url_official $url_cache $gitPackage
Verify-Checksum $gitPackage $sha1
Write-Host "Installing Git $version..."
Run-Executable "$gitPackage" "/SILENT /COMPONENTS=`"icons,ext\reg\shellhere,assoc,assoc_sh`""
Write-Host "Adding SSH and SCP to environment variables for RTA"
Set-EnvironmentVariable "SSH" "C:\Program Files\Git\usr\bin\ssh.exe"
Set-EnvironmentVariable "SCP" "C:\Program Files\Git\usr\bin\scp.exe"

Write-Output "Git = $version" >> ~\versions.txt
