# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install Mimer SQL


$version = "1107b"

$url_cache = "https://ci-files01-hki.ci.qt.io/input/windows/MimerSQLInstaller_x64_" + $version + ".exe"
$url_official = "https://install.mimer.com/qt/windows_" + $version + "/MimerSQLInstaller_x64.exe"
$mimersqlPackage = "C:\Windows\Temp\MimerSQLInstaller_x64_" + $version + ".exe"
$sha1 = "A709A06EA1D897B13FA10DBDD4BE3BD0FEB04B28"
$mimer_dir="c:\MimerSQL"

Download $url_official $url_cache $mimersqlPackage
Verify-Checksum $mimersqlPackage $sha1
Run-Executable "$mimersqlPackage" "/install InstallFolder=$mimer_dir /passive ExcludeDbVisualizer=1 ExcludeJava=1 ExcludeServer=1 ExcludeDocumentation=1 ExcludeReplication=1"

Set-EnvironmentVariable "MIMERSQL_DEV_ROOT" "$mimer_dir\dev"

Write-Host "Cleaning $mimersqlPackage.."
#Remove "$mimersqlPackage"
Remove "$mimer_dir\dev\include\odbcinst.h"
Remove "$mimer_dir\dev\include\Sql.h"
Remove "$mimer_dir\dev\include\sqlext.h"
Remove "$mimer_dir\dev\include\sqltypes.h"
Remove "$mimer_dir\dev\include\sqlucode.h"

Write-Output "Mimer SQL = $version" >> ~\versions.txt
