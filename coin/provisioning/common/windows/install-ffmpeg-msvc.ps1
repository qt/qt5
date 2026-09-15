# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

[CmdletBinding(PositionalBinding = $false)]
param (
    [string]$InstallDir,
    [string]$MsysBash,
    [string]$ZlibPath,
    [switch]$SkipEnvVar,
    [switch]$Help
)

. "$PSScriptRoot\install-ffmpeg-common.ps1"
. "$PSScriptRoot\zlib-helpers.ps1"

$HELP_MESSAGE = @"
install-ffmpeg-msvc.ps1 - Builds FFmpeg for Windows using MSVC.

Builds for the host architecture (amd64 or arm64).

Usage:
    install-ffmpeg-msvc.ps1 [-InstallDir <path>] [-MsysBash <path>] [-ZlibPath <path>] [-SkipEnvVar] [-Help]

Options:
    -InstallDir <path>  Directory to install the built FFmpeg artifacts into.
                        Defaults to a path under the extracted FFmpeg source.
    -MsysBash <path>    Path to the MSYS2 bash executable used to run the build.
                        Defaults to $msys.
    -ZlibPath <path>    Path to the zlib build folder to link against. Defaults
                        to the ZLIB_PATH_<arch> machine environment variable.
    -SkipEnvVar         Build without setting the FFMPEG_DIR_MSVC[_ARM64]
                        environment variable at the end. Allows the script to run
                        without elevated privileges.
    -Help               Show this help and exit.
"@

function ShowHelp {
    Write-Host $HELP_MESSAGE
}

function InstallMsvcFfmpeg {
    Param (
        [Parameter(Mandatory)]
        [string]$hostArch,
        [Parameter(Mandatory)]
        [bool]$isArm64,
        [string]$installDir,        # Optional override for where to install the build artifacts
        [string]$msysBash,          # Optional override for the MSYS bash executable
        [string]$zlibPath,          # Optional override for the zlib build folder
        [bool]$skipEnvVar = $false  # Optional:
                                    # Don't assign the FFmpeg dir environment variable.
                                    # Allows the function to run without elevated privileges.
    )

    $arch = "amd64"
    $buildSystem = "msvc"
    $ffmpegDirEnvVar = "FFMPEG_DIR_MSVC"

    $config = GetFfmpegDefaultConfiguration

    if ($isArm64) {
        $arch = "arm64"
        $buildSystem += "-arm64"
        $ffmpegDirEnvVar += "_ARM64"
        $config += " --arch=arm64 --disable-asm"
        if ($hostArch -eq "amd64") {
            $config += " --enable-cross-compile"
        }
    }

    if (-not $installDir) {
        $installDir = ResolveFFmpegInstallDir -buildSystem $buildSystem
    }

    # Fail fast if the bash path does not resolve to an executable
    $effectiveBash = if ($msysBash) { $msysBash } else { $msys }
    if (-not (Get-Command $effectiveBash -CommandType Application -ErrorAction SilentlyContinue)) {
        throw "MSYS bash executable not found: '$effectiveBash'"
    }

    if (-not $zlibPath) {
        $zlibPath = GetZlibPathByString -TargetArchitecture $arch
    }

    # Fail fast if the zlib path is missing or empty
    if (-not $zlibPath) {
        throw "No zlib path provided and ZLIB_PATH_$($arch.ToUpper()) is not set"
    }
    if (-not (Test-Path -Path $zlibPath -PathType Container) -or
        -not (Get-ChildItem -Path $zlibPath -Force -ErrorAction SilentlyContinue | Select-Object -First 1)) {
        throw "zlib path is not a populated directory: '$zlibPath'"
    }
    $zlibPathMsys = ConvertTo-MsysPath $zlibPath

    $config += " --enable-zlib"
    $config += " --extra-cflags=`"-I$zlibPathMsys`""
    $config += " --extra-ldflags=`"-LIBPATH:$zlibPathMsys`""

    $result = EnterVSDevShell -HostArch $hostArch -Arch $arch
    if (-Not $result) {
        return $false
    }

    # MSVC 2019 workaround: The SSA optimizer (code generation
    # "pass 2") gets stuck in an infinite loop on some translations
    # units, such as libavcodec/sanm.c, when compiling FFmpeg n8.1.2 and up.
    # This only affects the VS2019-based Windows 10 x86_64 image.
    # VS2022+ hosts build fine. Disabling that optimizer pass lets the
    # older toolchain finish. This workaround can be dropped once we no
    # longer build using MSVC 2019.
    if ($env:VisualStudioVersion -and [version]$env:VisualStudioVersion -lt [version]"17.0") {
        Write-Host "MSVC $env:VisualStudioVersion (< 2022) detected; adding -d2SSAOptimizer- to avoid build freeze on FFmpeg 8.x"
        $config += " --extra-cflags=-d2SSAOptimizer-"
    }

    $result = InstallFfmpeg -config $config -buildSystem $buildSystem -msystem "MSYS" -toolchain "msvc" -ffmpegDirEnvVar $ffmpegDirEnvVar -shared $true -installDir $installDir -msysBash $msysBash -skipEnvVar $skipEnvVar

    if ($result) {
        # As ffmpeg build system creates lib*.a file we have to rename them to *.lib files to be recognized by WIN32
        Write-Host "Rename libraries lib*.a -> *.lib"
        try {
            Get-ChildItem "$installDir\lib\lib*.a" | ForEach-Object {
                $NewName = $_.Name -replace 'lib(\w+).a$', '$1.lib'
                $Destination = Join-Path -Path $_.Directory.FullName -ChildPath $NewName
                Move-Item -Path $_.FullName -Destination $Destination -Force
            }
        } catch {
            Write-Host "Failed to rename libraries lib*.a -> *.lib"
            return $false
        }
    }

    return $result
}

# Run as a standalone script (skipped when dot-sourced)
if ($MyInvocation.InvocationName -ne '.') {
    if ($Help) {
        ShowHelp
        return
    }

    # Expand ~ and relative paths so they survive being handed to MSYS/MSVC.
    if ($InstallDir) { $InstallDir = Resolve-FullPath $InstallDir }
    if ($ZlibPath)   { $ZlibPath   = Resolve-FullPath $ZlibPath }
    if ($MsysBash)   { $MsysBash   = Resolve-FullPath $MsysBash }

    $cpuArch = Get-CpuArchitecture
    $hostArch = CpuArchToString -Architecture $cpuArch
    $isArm64 = $cpuArch -eq [CpuArch]::arm64

    GetFfmpegSource

    $result = InstallMsvcFfmpeg -hostArch $hostArch -isArm64 $isArm64 -installDir $InstallDir -msysBash $MsysBash -zlibPath $ZlibPath -skipEnvVar $SkipEnvVar.IsPresent

    exit $(if ($result) { 0 } else { 1 })
}
