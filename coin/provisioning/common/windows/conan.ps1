# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

$scriptsPath = [System.Environment]::GetEnvironmentVariable('PIP3_PATH', [System.EnvironmentVariableTarget]::Machine)
$version = "1.39.0"
Run-Executable "$scriptsPath\pip3.exe" "install conan==$version"
Write-Output "Conan = $version" >> ~\versions.txt

# Add conan to path.
Add-Path $scriptsPath
Set-EnvironmentVariable "CONAN_REVISIONS_ENABLED" "1"
Set-EnvironmentVariable "CONAN_V2_MODE" "1"

# This is temporary solution for installing packages provided by Conan until we have fixed Conan setup for this

$url_conan = "\\ci-files01-hki.ci.qt.io\provisioning\windows\.conan.zip"
$url_conan_home = "\\ci-files01-hki.ci.qt.io\provisioning\windows\.conanhome.zip"
$sha1_conan_compressed = "1abbe43e7a29ddd9906328702b5bc5231deeb721"
$sha1_conanhome_compressed = "f44c2ae21cb1c7dc139572e399b7b0eaf492af03"
$conan_compressed = "C:\.conan.zip"
$conanhome_compressed = "C:\.conanhome.zip"

Download $url_conan $url_conan $conan_compressed
Verify-Checksum $conan_compressed $sha1_conan_compressed
Extract-7Zip $conan_compressed C:\

Download $url_conan_home $url_conan_home $conanhome_compressed
Verify-Checksum $conanhome_compressed $sha1_conanhome_compressed
Extract-7Zip $conanhome_compressed C:\Users\qt

Remove $conan_compressed
Remove $conanhome_compressed

# Remove existing settings file to generate a new.
Remove "C:\Users\qt\.conan\settings.yml"
