# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script installs sed and it's dependencies

$prog = "sed"
$version = "4.2.1"
$sha1 = "dfd3d1dae27a24784d7ab40eb074196509fa48fe"
$dep_sha1 = "f7edbd7152d8720c95d46dd128b87b8ba48a5d6f"
$pkg = "$prog-$version-bin.zip"
$dep_pkg = "$prog-$version-dep.zip"
$cached_url = "http://ci-files01-hki.ci.qt.io/input/windows/gnuwin32/$pkg"
$dep_cached_url = "http://ci-files01-hki.ci.qt.io/input/windows/gnuwin32/$dep_pkg"
$install_location = "c:\Utils\$prog"

$tmp_location = "c:\users\qt\downloads"
Download $cached_url $cached_url "$tmp_location\$pkg"
Verify-Checksum "$tmp_location\$pkg" $sha1 sha1
Download $dep_cached_url $dep_cached_url "$tmp_location\$dep_pkg"
Verify-Checksum "$tmp_location\$dep_pkg" $dep_sha1 sha1

Extract-7Zip "$tmp_location\$pkg" $install_location
Extract-7Zip "$tmp_location\$dep_pkg" $install_location
Remove "$tmp_location\$pkg"
Remove "$tmp_location\$dep_pkg"

Prepend-Path "$install_location\bin"
Write-Output "sed = $version" >> ~/versions.txt
