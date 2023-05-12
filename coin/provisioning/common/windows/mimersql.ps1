# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install Mimer SQL


$version = "1107b"

$url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\MimerSqlX64Windows" + $version + ".exe"
$url_official = "https://download.mimer.com/pub/dist/windows/MimerSqlX64Windows" + $version + ".exe"
$mimersqlPackage = "C:\Windows\Temp\MimerSqlX64Windows" + $version + ".exe"
$sha1 = "e27bb6bdbd5cbd895a64b70051e3e5346f738957"
Download $url_official $url_cache $mimersqlPackage
Verify-Checksum $mimersqlPackage $sha1
Run-Executable "$mimersqlPackage" "/install /passive"

Write-Host "Cleaning $mimersqlPackage.."
Remove "$mimersqlPackage"
Remove "C:\Program Files\Mimer SQL Experience 11.0\dev\include\odbcinst.h"
Remove "C:\Program Files\Mimer SQL Experience 11.0\dev\include\Sql.h"
Remove "C:\Program Files\Mimer SQL Experience 11.0\dev\include\sqlext.h"
Remove "C:\Program Files\Mimer SQL Experience 11.0\dev\include\sqltypes.h"
Remove "C:\Program Files\Mimer SQL Experience 11.0\dev\include\sqlucode.h"

Write-Output "Mimer SQL = $version" >> ~\versions.txt
