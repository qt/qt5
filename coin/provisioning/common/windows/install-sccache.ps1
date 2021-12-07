#############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
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

# Install mozilla sccache

param(
    [string]$arch="x86_64-pc-windows-msvc",
    [string]$version="0.2.14",
    [string]$sha1="bbdceb59d6fd7b6a3af02fb36f65c8bf324757b0"
)

. "$PSScriptRoot\helpers.ps1"

$basename = "sccache-" + $version + "-" + $arch
$zipfile = $basename + ".tar.gz"
$tempfile = "C:\Windows\Temp\" + $zipfile
$urlCache = "http://ci-files01-hki.intra.qt.io/input/sccache/" + $zipfile
$urlOfficial = "https://github.com/mozilla/sccache/releases/download/" + $version + "/" + $zipfile
$targetFolder = "C:\Program Files\"

Write-Host "Downloading sccache $version..."
Download $urlOfficial $urlCache $tempfile
Verify-Checksum $tempfile $sha1
Write-Host "Extracting $tempfile to $targetFolder..."
Extract-tar_gz $tempfile $targetFolder
Remove-Item -Path $tempfile

# Turnoff idle timeout to avoid sccache shutting down
Set-EnvironmentVariable "SCCACHE_IDLE_TIMEOUT" "0"

# add sccache to PATH
Set-EnvironmentVariable "PATH" "C:\Program Files\$basename\;$([Environment]::GetEnvironmentVariable('PATH', 'Machine'))"

# update versions
Write-Output "sccache = $version" >> ~\versions.txt
