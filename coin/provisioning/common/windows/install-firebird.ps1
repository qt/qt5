# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script installs firebird $version.

$version = "5.0.1"
$fullversion = "$version.1469-0"
$packagex64 = "C:\Windows\temp\Firebird-$fullversion-windows-x64.zip"

# Install x64 bit versions
$installFolder = "C:\Utils\firebird"
$externalUrl = "https://github.com/FirebirdSQL/firebird/releases/download/v$version/Firebird-$fullversion-windows-x64.zip"
$internalUrl = "http://ci-files01-hki.ci.qt.io/input/windows/firebird/Firebird-$fullversion-windows-x64.zip"
$sha1 = "7b56ea692215b128415ef9599e18c40bef12152f"

Write-Host "Fetching from URL ..."
Download $externalUrl $internalUrl $packagex64
Verify-Checksum $packagex64 $sha1
Write-Host "Installing $packagex64 ..."
Extract-7Zip $packagex64 $installFolder

Write-Host "Remove downloaded $packagex64 ..."
Remove $packagex64

Set-EnvironmentVariable "Interbase_ROOT" "$installFolder"

# Store version information to ~/versions.txt, which is used to print version information to provision log.
Write-Output "Firebird = $fullversion" >> ~/versions.txt
