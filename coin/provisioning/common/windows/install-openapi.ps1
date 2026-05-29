# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# openapi is needed for qtopenapi project

. "$PSScriptRoot\helpers.ps1"

$version = "7.18.0"

$temp = "$env:tmp"
Write-Host "Fetching openapi generator ver. $version..."
$url_cache = "http://ci-files01-hki.ci.qt.io/input/qtopenapi/openapi_client_generators/openapi-generator-cli-$version.jar"
$url_official = "https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/$version/openapi-generator-cli-$version.jar"
$target_file = "openapi-generator-cli.jar"
$sha1 = "8bd615a50b15ebf5be30e612af112526a6e81ac4"

Download $url_official $url_cache "$temp\$target_file"
Verify-Checksum "$temp\$target_file" $sha1

$openapi_location = "C:\Utils\qt-openapi"
Write-Host "Copying $target_file to $openapi_location"
New-Item -Path "$openapi_location" -ItemType Directory
Move-Item "$temp\$target_file" "$openapi_location\$target_file"

Prepend-Path "$openapi_location"

Write-Output "OpenAPI generator = $version" >> ~/versions.txt

# Extract baseline cache for openapi
$pkgname = "maven_cache-openapi-$version.tar.gz"
$url_cache = "http://ci-files01-hki.ci.qt.io/input/qtopenapi/maven/$pkgname"
$sha1 = "e397b7934a8c892753166435aff8775c0b5aa5bf"

Download $url_cache $url_cache "$temp\$pkgname"
Verify-Checksum "$temp\$pkgname" $sha1
$cache_location = "C:\Users\qt"
Write-Host "Extracting $pkgname to $cache_location"
Extract-tar_gz "$temp\$pkgname" "$cache_location"
