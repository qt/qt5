#############################################################################
##
## Copyright (C) 2023 The Qt Company Ltd.
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

# This script installs MySQL $version.
# Both x86 and x64 versions needed when x86 integrations are done on x64 machine

$version = "6.1.11"
$installFolder = "C:\Utils"
$officialUrl = "https://downloads.mysql.com/archives/get/p/19/file/mysql-connector-c-${version}-winx64.zip"
$officialUrlDebug = "https://downloads.mysql.com/archives/get/p/19/file/mysql-connector-${version}-winx64-debug.zip"
$cacheURl = "http://ci-files01-hki.ci.qt.io/input/windows/mysql-connector-c-${version}-winx64.zip"
$cacheURlDebug = "http://ci-files01-hki.ci.qt.io/input/windows/mysql-connector-c-${version}-winx64-debug.zip"
$sha = "93e22a1ba3944a6c8e01d3ea04c1bfb005b238f9"
$shaDebug = "d54088a9182e2f03b4d6f44c327e341eeab16367"
$zip = Get-DownloadLocation ("mysql-connector-c-" + $version + "-winx64.zip")
$zipDebug = Get-DownloadLocation ("mysql-connector-c-" + $version + "-winx64-debug.zip")

function Install {
    param(
        [string]$officialUrl,
        [string]$cacheUrl,
        [string]$zip,
        [string]$sha
    )

    Download $officialUrl $cacheURl $zip
    Verify-Checksum $zip $sha
    Extract-7Zip $zip $installFolder
    Remove $zip
}

Install $officialUrl $cacheURl $zip $sha
Install $officialUrlDebug $cacheURlDebug $zipDebug $shaDebug

# Can't set MySQL_ROOT & MySQL_LIBRARY_DIR variables. Those will enable mysql in every windows target.
# Let's use ENV_MySQL_* and use it in platform_configs
Set-EnvironmentVariable "ENV_MySQL_ROOT" "${installFolder}\mysql-connector-c-${version}-winx64"
Set-EnvironmentVariable "ENV_MySQL_LIBRARY_DIR" "${installFolder}\mysql-connector-c-${version}-winx64\lib\vs14"

Write-Output "MySQL = $version" >> ~/versions.txt
