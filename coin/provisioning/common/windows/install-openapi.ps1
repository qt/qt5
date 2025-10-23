# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# openapi is needed for qtopenapi project

. "$PSScriptRoot\helpers.ps1"

$version = "7.15.0"

$temp = "$env:tmp"
Write-Host "Fetching openapi generator ver. $version..."
$url_cache = "http://ci-files01-hki.ci.qt.io/input/qtopenapi/openapi_client_generators/openapi-generator-cli-$version.jar"
$url_official = "https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/$version/openapi-generator-cli-$version.jar"
$target_file = "openapi-generator-cli.jar"
$sha1 = "bb58e257f724fb46b7f2b309a9fa98e63fd7199f"

Download $url_official $url_cache "$temp\$target_file"
Verify-Checksum "$temp\$target_file" $sha1

$openapi_location = "C:\Utils\qt-openapi"
Write-Host "Copying $target_file to $openapi_location"
New-Item -Path "$openapi_location" -ItemType Directory
Move-Item "$temp\$target_file" "$openapi_location\$target_file"

Prepend-Path "$openapi_location"

Write-Output "OpenAPI generator = $version" >> ~/versions.txt
