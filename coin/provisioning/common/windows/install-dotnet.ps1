#############################################################################
##
## Copyright (C) 2020 The Qt Company Ltd.
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

# This script will install Dotnet SDK which is required for Azure installation

$version = "2.1"
if (Is64BitWinHost) {
    $urlCache = "http://ci-files01-hki.intra.qt.io/input/windows/dotnet-sdk-2.1.809-win-x64.exe"
    $urlOfficial = "https://download.visualstudio.microsoft.com/download/pr/c980b6fb-e570-4c73-b344-e4dae6573777/f844ac1a4c6ea5de7227a701786126fd/dotnet-sdk-2.1.809-win-x64.exe"
    $sha1 = "343e80c2ab558a30696dbe03ad2288bf435d5cd8"
} else {
    $urlCache = "http://ci-files01-hki.intra.qt.io/input/windows/dotnet-sdk-2.1.809-win-x86.exe"
    $urlOfficial = "https://download.visualstudio.microsoft.com/download/pr/cf86a2f3-f6b2-4959-8e41-cf84b0d2f294/a61e834f56abe2dc2e12599e1a60c10b/dotnet-sdk-2.1.809-win-x86.exe"
    $sha1 = "b38a4e1392f17aed110508a1687f1c65b9d86161"
}
$installer = "C:\Windows\Temp\dotnet-sdk-$version.exe"

Write-Host "Installing Dotnet SDK $version"
Download $urlOfficial $urlCache $installer
Verify-Checksum $installer $sha1
Run-Executable "$installer" "/install /passive"
Prepend-Path "C:\Program Files\dotnet"
Remove $installer

Write-Output "Dotnet SDK = $version" >> ~/versions.txt



