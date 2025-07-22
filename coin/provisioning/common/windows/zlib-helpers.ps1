# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

function CpuArchToString {
    param (
        [Parameter(Mandatory)]
        [CpuArch] $Architecture
    )

    $arhitecture = switch ($Architecture) {
        ([CpuArch]::arm64) {
            'arm64'
        }
        ([CpuArch]::x64) {
            'amd64'
        }
        default {
            throw "Unsupported architecture: '$Architecture'"
        }
    }

    return $arhitecture
}

function StringToCpuArch {
    param (
        [Parameter(Mandatory)]
        [string] $Architecture
    )

    $arhitecture = switch ($Architecture) {
        'arm64' {
            [CpuArch]::arm64
        }
        'amd64' {
            [CpuArch]::x64
        }
        default {
            throw "Unsupported architecture: '$Architecture'"
        }
    }

    return $arhitecture
}

function GetZlibEnvironmentVariableName {
    param (
        [Parameter(Mandatory)]
        [CpuArch] $TargetArchitecture
    )

    $architecture  = CpuArchToString -Architecture $TargetArchitecture
    $environmentVariableName = "ZLIB_PATH_$architecture".ToUpper()

    return $environmentVariableName
}

function GetZlibPathByCpuArch {
    param (
        [Parameter(Mandatory)]
        [CpuArch] $TargetArchitecture
    )

    $environmentVariableName = GetZlibEnvironmentVariableName -TargetArchitecture $TargetArchitecture

    return [System.Environment]::GetEnvironmentVariable($environmentVariableName, [System.EnvironmentVariableTarget]::Machine)
}

function GetZlibPathByString {
    param (
        [Parameter(Mandatory)]
        [string] $TargetArchitecture
    )

    $targetArchitecture = StringToCpuArch -Architecture $TargetArchitecture

    return GetZlibPathByCpuArch -TargetArchitecture $targetArchitecture
}
