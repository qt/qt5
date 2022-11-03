############################################################################
##
## Copyright (C) 2021 The Qt Company Ltd.
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
############################################################################

. "$PSScriptRoot\helpers.ps1"

$scriptsPath = [System.Environment]::GetEnvironmentVariable('PIP3_PATH', [System.EnvironmentVariableTarget]::Machine)
$version = "1.39.0"
Run-Executable "$scriptsPath\pip3.exe" "install conan==$version"
Write-Output "Conan = $version" >> ~\versions.txt

# Add conan to path.
Add-Path $scriptsPath
Set-EnvironmentVariable "CONAN_REVISIONS_ENABLED" "1"
Set-EnvironmentVariable "CONAN_V2_MODE" "1"

# This is temporary solution for installing packages provided by Conan until we have fixed Conan setup for this

$url_conan = "\\ci-files01-hki.intra.qt.io\provisioning\windows\.conan.zip"
$url_conan_home = "\\ci-files01-hki.intra.qt.io\provisioning\windows\.conanhome.zip"
$sha1_conan_compressed = "1abbe43e7a29ddd9906328702b5bc5231deeb721"
$sha1_conanhome_compressed = "f44c2ae21cb1c7dc139572e399b7b0eaf492af03"
$conan_compressed = "C:\.conan.zip"
$conanhome_compressed = "C:\.conanhome.zip"

Download $url_conan $url_conan $conan_compressed
Verify-Checksum $conan_compressed $sha1_conan_compressed
Extract-7Zip $conan_compressed C:\

Download $url_conan_home $url_conan_home $conanhome_compressed
Verify-Checksum $conanhome_compressed $sha1_conanhome_compressed
Extract-7Zip $conanhome_compressed C:\Users\qt

Remove $conan_compressed
Remove $conanhome_compressed

# Remove existing settings file to generate a new.
Remove "C:\Users\qt\.conan\settings.yml"
