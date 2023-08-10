############################################################################
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

# This script will install Mimer SQL


$version = "1107b"

$url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\MimerSQLInstaller_x64_" + $version + ".exe"
$url_official = "https://install.mimer.com/qt/windows_" + $version + "/MimerSQLInstaller_x64.exe"
$mimersqlPackage = "C:\Windows\Temp\MimerSQLInstaller_x64_" + $version + ".exe"
$sha1 = "A709A06EA1D897B13FA10DBDD4BE3BD0FEB04B28"
$mimer_dir="c:\MimerSQL"

Download $url_official $url_cache $mimersqlPackage
Verify-Checksum $mimersqlPackage $sha1
Run-Executable "$mimersqlPackage" "/install InstallFolder=$mimer_dir /passive"

Set-EnvironmentVariable "MIMERSQL_DEV_ROOT" "$mimer_dir\dev"

Write-Host "Cleaning $mimersqlPackage.."
#Remove "$mimersqlPackage"
Remove "$mimer_dir\dev\include\odbcinst.h"
Remove "$mimer_dir\dev\include\Sql.h"
Remove "$mimer_dir\dev\include\sqlext.h"
Remove "$mimer_dir\dev\include\sqltypes.h"
Remove "$mimer_dir\dev\include\sqlucode.h"

Write-Output "Mimer SQL = $version" >> ~\versions.txt
