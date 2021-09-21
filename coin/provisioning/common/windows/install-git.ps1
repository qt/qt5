#############################################################################
##
## Copyright (C) 2021 The Qt Company Ltd.
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
. "$PSScriptRoot\helpers.ps1"

# Install Git version 2.31.0

$version = "2.31.0"
if (Is64BitWinHost) {
    $arch = "-64-bit"
    $sha1 = "495d78f8d961e030944d9cb53af80d909d493c3f"
} else {
    $arch = "-32-bit"
    $sha1 = "e57c040aea297b363aefaf26424f2e7a84a4a173"
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
