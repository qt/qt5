# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
. "$PSScriptRoot\helpers.ps1"

# This script allows the Windows Remote Desktop Access

Run-Executable "reg.exe" "add `"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server`" /v fDenyTSConnections /t REG_DWORD /d 0 /f"
