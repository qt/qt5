############################################################################
##
## Copyright (C) 2018 The Qt Company Ltd.
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

# This script will install Windows 10 SDK

$url_cache = "\\ci-files01-hki.intra.qt.io\provisioning\windows\winsdksetup.exe"
$url_official = "https://download.microsoft.com/download/8/C/3/8C37C5CE-C6B9-4CC8-8B5F-149A9C976035/windowssdk/winsdksetup.exe"
$package = "C:\Windows\Temp\winsdksetup.exe"
$sha1 = "db237323f1779fb143e7cdc558e4345e7004489e"

Copy-Item $url_cache $package
Verify-Checksum $package $sha1
Run-Executable $package "/features + /q"

Write-Host "Cleaning $package.."
Remove "$package"

Write-Output "Windows 10 SDK = 10.0.16229.91" >> ~\versions.txt
