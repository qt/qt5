# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script performs manual copying and patching of the zlib source to support
# multi-architecture builds on Windows using Microsoft's nmake and Makefile.msc.
#
# Reasons for this approach:
#
# 1. In-source build system:
#    zlib's build system (Makefile.msc) writes all build artifacts directly into the source
#    directory. To allow concurrent builds for different architectures (e.g., x64 and arm64),
#    we copy the relevant source files into per-architecture build directories to isolate artifacts.
#
# 2. Incompatible linker base address:
#    The default Makefile.msc contains a hardcoded image base address ('-base:0x5A4C0000') for the
#    linker. This is invalid for ARM64 targets, which require base addresses above 4 GB. The script
#    patches this line out to prevent linker errors.
#
# 3. Broken #include in zconf.h:
#    Based on FFmpeg documentation (https://ffmpeg.org/platform.html#Microsoft-Visual-C_002b_002b-or-Intel-C_002b_002b-Compiler-for-Windows),
#    zconf.h may erroneously include '<unistd.h>', which doesn't exist on Windows. While Visual Studio 2022
#    builds tolerate this, we patch it out to ensure compatibility with older toolchains.
#
# These workarounds allow us to run reproducible, architecture-specific builds in CI without modifying
# the original source tree or requiring upstream changes.

. "$PSScriptRoot\helpers.ps1"
. "$PSScriptRoot\zlib-helpers.ps1"

$VERSION='1.3.1'
$SHA1='f535367b1a11e2f9ac3bec723fb007fbc0d189e5'

$WIN32_DIRECTORY='win32'
$MAKEFILE="$WIN32_DIRECTORY\Makefile.msc"

function BuildZlib {
    param (
        [Parameter(Mandatory)]
        [CpuArch] $HostArchitecture,
        [Parameter(Mandatory)]
        [CpuArch] $TargetArchitecture
    )

    PrepareBuildEnvironment -HostArchitecture $HostArchitecture -TargetArchitecture $TargetArchitecture
    Invoke-NMake -NmakeArgs @('/f', "$MAKEFILE")
}

function CopySource {
    param (
        [Parameter(Mandatory)]
        [CpuArch] $TargetArchitecture
    )

    $testDirectory='test'

    $buildDirectory = GetBuildDirectory -TargetArchitecture $TargetArchitecture
    $win32BuildDirectory = "$buildDirectory\$WIN32_DIRECTORY"
    $testBuildDirectory = "$buildDirectory\$testDirectory"

    New-Item -Path $buildDirectory -ItemType 'Directory'
    New-Item -Path $win32BuildDirectory -ItemType 'Directory'
    New-Item -Path $testBuildDirectory -ItemType 'Directory'

    Copy-Item '*' -Include '*.c','*.h' -Destination $buildDirectory
    Copy-Item "$WIN32_DIRECTORY\*" -Include '*.def','*.msc','*.rc' -Destination $win32BuildDirectory
    Copy-Item "$testDirectory\*" -Include '*.c' -Destination $testBuildDirectory
}

function GetBuildDirectory {
    param (
        [Parameter(Mandatory)]
        [CpuArch] $TargetArchitecture
    )

    $architectureDirectory  = CpuArchToString -Architecture $TargetArchitecture

    return "build\$architectureDirectory"
}

function GetSource {
    $unzipDirectory = "C:\"
    $zlibName="zlib-$VERSION"

    $zlibDirectory = "$unzipDirectory$zlibName"

    $urlCached="http://ci-files01-hki.ci.qt.io/input/zlib/zlib-$VERSION.tar.gz"
    $urlPublic="https://github.com/madler/zlib/releases/download/v$VERSION/zlib-$VERSION.tar.gz"

    $downloadPath = "C:\Windows\Temp\$zlibName.tar.gz"

    Write-Host "Fetching zlib $VERSION..."

    Download $urlPublic $urlCached $downloadPath
    Verify-Checksum $downloadPath $SHA1
    Extract-tar_gz $downloadPath $unzipDirectory
    Remove $downloadPath

    return $zlibDirectory
}

function GetTargetArchitectures {
    param (
        [Parameter(Mandatory)]
        [CpuArch] $HostArchitecture
    )

    $targetArhitectures = @([CpuArch]::arm64)

    if ($HostArchitecture -eq [CpuArch]::x64) {
        $targetArhitectures += [CpuArch]::x64
    }

    return $targetArhitectures
}

function PatchMakefile {
    $pattern = '-base:\s*0x[0-9A-Fa-f]+'

    (Get-Content $MAKEFILE) | ForEach-Object {
        $_ -replace $pattern, ''
    } | Set-Content $MAKEFILE
}

function PatchSource {
    PatchZconf
    PatchMakefile
}

function PatchZconf {
    $zconf = 'zconf.h'
    $pattern = '#\s*include\s*<unistd\.h>'

    (Get-Content $zconf) | Where-Object {
        $_ -notmatch $pattern
    } | Set-Content $zconf
}

function PrepareBuild {
    param (
        [Parameter(Mandatory)]
        [CpuArch] $TargetArchitecture
    )

    CopySource -TargetArchitecture $TargetArchitecture
}

function PrepareBuildEnvironment {
    param (
        [Parameter(Mandatory)]
        [CpuArch] $HostArchitecture,
        [Parameter(Mandatory)]
        [CpuArch] $TargetArchitecture
    )

    $hostArhitecture = CpuArchToString -Architecture $HostArchitecture
    $targetArhitecture = CpuArchToString -Architecture $TargetArchitecture

    if (-not $(EnterVSDevShell -HostArch $hostArhitecture -Arch $targetArhitecture)) {
        throw "Failed to prepare build environment for ${hostArhitecture}_${targetArhitecture}"
    }
}

function SetZlibEnvironmentVariable {
    param (
        [Parameter(Mandatory)]
        [CpuArch] $TargetArchitecture,
        [Parameter(Mandatory)]
        [string] $ZlibDirectory
    )

    $buildDirectory = GetBuildDirectory -TargetArchitecture $TargetArchitecture
    $environmentVariableName = GetZlibEnvironmentVariableName -TargetArchitecture $TargetArchitecture
    $environmentVariableValue = "$ZlibDirectory\$buildDirectory"

    Set-EnvironmentVariable $environmentVariableName $environmentVariableValue
}

$zlibDirectory = GetSource
$hostArchitecture = Get-CpuArchitecture
$targetArchitectures = GetTargetArchitectures -HostArchitecture $hostArchitecture

Push-Location $zlibDirectory

try {
    foreach ($targetArchitecture in $targetArchitectures) {
        PrepareBuild -TargetArchitecture $targetArchitecture

        $buildDirectory = GetBuildDirectory -TargetArchitecture $targetArchitecture
        Push-Location $buildDirectory

        try {
            PatchSource
            BuildZlib -HostArchitecture $hostArchitecture -TargetArchitecture $targetArchitecture
            SetZlibEnvironmentVariable -TargetArchitecture $targetArchitecture -ZlibDirectory $zlibDirectory
        }
        finally {
            Pop-Location
        }
    }
}
finally {
    Pop-Location
}
