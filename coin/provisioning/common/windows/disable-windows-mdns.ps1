# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script disables device discovery services related to Windows mDNS multicast

. "$PSScriptRoot\helpers.ps1"

# Miracast / Wireless Display
$regPath2 = "HKLM:\Software\Policies\Microsoft\Windows\Connect"
New-Item -Path $regPath2 -Force | Out-Null
Set-ItemProperty -Path $regPath2 -Name "DisableWirelessDisplay" -Type DWord -Value 1

# Function Discovery Resource Publication, printer/service publisher
Stop-Service -Name FDResPub
Set-Service -Name FDResPub -StartupType Disabled

# Windows Media Player Network Sharing Service
Stop-Service -Name WMPNetworkSvc -Force
Set-Service -Name WMPNetworkSvc -StartupType Disabled

# Function Discovery Provider Host
Stop-Service -Name fdPHost
Set-Service -Name fdPHost -StartupType Disabled

# Windows Connect Now
Stop-Service -Name wcncsvc
Set-Service -Name wcncsvc -StartupType Disabled
