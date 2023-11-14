# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script installs jq

$jqProgram = "jq"
$jqVersion = "1.6"
$jqExeSHA1 = "2b7ae7b902aa251b55f2fd73ad5b067d2215ce78"
$jqInstallLocation = "C:\Utils\jq"
$jqExe = "C:\Windows\Temp\jq.exe"
$jqCacheURL = "\\ci-files01-hki.ci.qt.io\provisioning\jq\jq-win64-$jqVersion.exe"
$jqOfficialURL = "https://github.com/jqlang/jq/releases/download/jq-$jqVersion/jq-win64.exe"

Download "$jqOfficialURL" "$jqCacheURL" "$jqExe"
Verify-Checksum $jqExe $jqExeSHA1
New-Item -Path "C:\Utils" -Name "jq" -ItemType "directory" -Force
Move-Item -Path "$jqExe" -Destination "$jqInstallLocation" -Force

if(![System.IO.File]::Exists("$jqInstallLocation\jq.exe")){
    Write-Host "Can't find $jqInstallLocation\jq.exe."
    exit 1
}

# Add jq to Path. It is necessary to prepend it to $env:Path as well, to make
# it available during provisioning
Prepend-Path "$jqInstallLocation"
$env:Path = "$jqInstallLocation;$env:Path"

Write-Output "jq = $jqVersion" >> ~/versions.txt
