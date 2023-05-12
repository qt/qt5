# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

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
