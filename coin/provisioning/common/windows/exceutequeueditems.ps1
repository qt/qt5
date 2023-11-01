# Copyright (C) 2018 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
. "$PSScriptRoot\helpers.ps1"

function ngen() {
    Param (
        [ValidateSet("Framework","Framework64","FrameworkArm64")][string]$framework
    )
    Start-Process -NoNewWindow -FilePath "C:\WINDOWS\Microsoft.NET\$framework\v4.0.30319\ngen.exe" -ArgumentList ExecuteQueuedItems -Wait
}

$cpu_arch = Get-CpuArchitecture
switch ($cpu_arch) {
    arm64 {
        ngen("FrameworkArm64")
        Break
    }
    x64 {
        ngen("Framework")
        ngen("Framework64")
        Break
    }
    x86 {
        ngen("Framework")
        Break
    }
    default {
        throw "Unknown architecture $cpu_arch"
    }
}
