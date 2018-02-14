############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
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

# This script will install Notepad++

$version = "7.3"
if (Is64BitWinHost) {
    $arch = ".x64"
    $sha1 = "E7306DF1D6E81801FB4BE0868610DB70E979B0AA"
} else {
    $arch = ""
    $sha1 = "d4c403675a21cc381f640b92e596bae3ef958dc6"
}
$url_cache = "\\ci-files01-hki.intra.qt.io\provisioning\windows\npp." + $version + ".Installer" + $arch + ".exe"
$url_official = "https://notepad-plus-plus.org/repository/7.x/" + $version + "/npp." + $version + ".Installer" + $arch + ".exe"
$nppPackage = "C:\Windows\Temp\npp-$version.exe"

Download $url_official $url_cache $nppPackage
Verify-Checksum $nppPackage $sha1
Run-Executable "$nppPackage" "/S"

Write-Host "Cleaning $nppPackage.."
Remove-Item -Recurse -Force -Path "$nppPackage"

Write-Output "Notepad++ = $version" >> ~\versions.txt

Write-Host "Disabling auto updates."
Rename-Item -Path "C:\Program Files\Notepad++\updater" -NewName "updater_disabled"
