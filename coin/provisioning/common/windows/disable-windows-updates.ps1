# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script disables the automatic Windows updates

. "$PSScriptRoot\helpers.ps1"

$service = get-service wuauserv
if (-not $service) {
    Write-Host "Windows Update service not found."
    exit 0
}

if ($service.Status -eq "Stopped") {
    Write-Host "Windows Update service already stopped."
} else {
    Write-Host "Stopping Windows Update service."
    Retry {Stop-Service -Name "wuauserv" -Force} 20 5
}

$startup = Get-WmiObject Win32_Service | Where-Object {$_.Name -eq "wuauserv"} | Select -ExpandProperty "StartMode"
if ($startup -ne "Disabled") {
    set-service wuauserv -startup disabled
} else {
    Write-Host "Windows Update service startup already disabled."
}
