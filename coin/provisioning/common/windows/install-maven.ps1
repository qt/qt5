# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install maven 3.9.11
$version = "3.9.11"

$temp = "$env:tmp"
Write-Host "Fetching maven ver. $version..."
$pkgname = "apache-maven-$version-bin.tar.gz"
$url_cache = "http://ci-files01-hki.ci.qt.io/input/qtopenapi/maven/$pkgname"
$url_official = "https://dlcdn.apache.org/maven/maven-3/$version/binaries/$pkgname"
$sha1 = "c084cde986ba878da4370bde009ab0a0a1936343"

Download $url_official $url_cache "$temp\$pkgname"
Verify-Checksum "$temp\$pkgname" $sha1

$maven_location = "C:\Utils\maven"
Write-Host "Extracting $pkgname to $maven_location"
New-Item -Path "$maven_location" -ItemType Directory
Extract-tar_gz "$temp\$pkgname" "$maven_location"

$dirname = "apache-maven-$version"
Prepend-Path "$maven_location\$dirname\bin"

Write-Output "Maven = $version" >> ~/versions.txt
