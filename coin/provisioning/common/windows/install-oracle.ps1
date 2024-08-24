# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script installs oci (Oracle Instant Client) $version.
# https://download.oracle.com/otn_software/nt/instantclient/2340000/instantclient-basiclite-windows.x64-23.4.0.24.05.zip
# https://download.oracle.com/otn_software/nt/instantclient/2340000/instantclient-sdk-windows.x64-23.4.0.24.05.zip

$version = "23.4.0.24.05"
$distdir = "instantclient_23_4"
$tmpdir = "C:\Windows\temp"
$installFolder = "C:\Utils\oracle"
$baseurl_ext = "https://download.oracle.com/otn_software/nt/instantclient/2340000"
$baseurl_int = "\\ci-files01-hki.ci.qt.io\provisioning\windows\oracle"

# basic files (dlls) - maybe not even needed for compilation only
$zipfile = "instantclient-basiclite-windows.x64-${version}.zip"
$package = "${tmpdir}\${zipfile}"
$sha1 = "05b22e6d17daad5c3e5908a2bd9d59e4aa457a30"

Write-Host "Fetching from URL ..."
Download "${baseurl_ext}/${zipfile}" "${baseurl_int}\${zipfile}" $package
Verify-Checksum $package $sha1
Write-Host "Installing $package ..."
Extract-7Zip $package $installFolder
Write-Host "Remove downloaded $package ..."
Remove $package

# SDK (lib + header)
$zipfile = "instantclient-sdk-windows.x64-${version}.zip"
$package = "C:\Windows\temp\${zipfile}"
$sha1 = "37305fd653cf52850237ddff4ed71ad61d04a5ee"

Write-Host "Fetching from URL ..."
Download "${baseurl_ext}/${zipfile}" "${baseurl_int}\${zipfile}" $package
Verify-Checksum $package $sha1
Write-Host "Installing $package ..."
Extract-7Zip $package $installFolder
Write-Host "Remove downloaded $package ..."
Remove $package

Set-EnvironmentVariable "Oracle_ROOT" "$installFolder\${distdir}\sdk\"

# Store version information to ~/versions.txt, which is used to print version information to provision log.
Write-Output "Oracle Instant Client = $version" >> ~/versions.txt
