# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script installs MySQL $version.
# Both x86 and x64 versions needed when x86 integrations are done on x64 machine

$version = "8.0.36"
$installFolder = "C:\Utils"
$officialUrl = "https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-${version}-winx64.zip"
$cacheURl = "http://ci-files01-hki.ci.qt.io/input/windows/mysql-${version}-winx64.zip"
$sha = "e5003569386006ccde9000c98e28e28073c1433d"
$zip = Get-DownloadLocation ("mysql-" + $version + "-winx64.zip")

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

# Can't set MySQL_ROOT & MySQL_LIBRARY_DIR variables. Those will enable mysql in every windows target.
# Let's use ENV_MySQL_* and use it in platform_configs
Set-EnvironmentVariable "ENV_MySQL_ROOT" "${installFolder}\mysql-${version}-winx64"
Set-EnvironmentVariable "ENV_MySQL_LIBRARY_DIR" "${installFolder}\mysql-${version}-winx64\lib"

Write-Output "MySQL = $version" >> ~/versions.txt
