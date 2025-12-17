# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

$script:nugetVersion = "v6.11.0"
$script:nugetPackage = "nuget_$nugetVersion.exe"
$script:packageRoot = "C:\Utils\NuGet\"

$script:cachedUrl = "\\ci-files01-hki.ci.qt.io\provisioning\windows\nuget\$nugetPackage"
$script:officialUrl = "https://dist.nuget.org/win-x86-commandline/$nugetVersion/nuget.exe"
$script:sdkChecksumSha1 = "5443887cfb5283da5021388d146ebb5febdc82e9"
$script:package_path = "$packageRoot\\$nugetPackage"

New-Item -ItemType Directory -Path "$packageRoot"
Download $officialUrl $cachedUrl $package_path
Verify-Checksum $package_path $sdkChecksumSha1 sha1
Write-Host "Installing Nuget"

Set-EnvironmentVariable "NUGET_EXE_PATH" "$package_path"
