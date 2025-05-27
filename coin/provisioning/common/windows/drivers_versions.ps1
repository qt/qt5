# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script will output usable drivers' versions in provision log

function LogDriverVersion
{
    Param (
        [string]$Name = $(BadParam("a name of the driver"))
    )

    $version = (Get-WmiObject Win32_PnPSignedDriver -Filter "DeviceName = '$Name'" | Format-Table Driverversion -HideTableHeaders | Out-String).Trim()
    if ([string]::IsNullOrEmpty($version) -eq $true) {
        Write-Host "No driver version found: '$Name'"
        return
    }

    Write-Host "$Name = $version"
}

LogDriverVersion "VirtIO Serial Driver"
