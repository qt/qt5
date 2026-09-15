# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\install-ffmpeg-common.ps1"
. "$PSScriptRoot\zlib-helpers.ps1"

function InstallMsvcFfmpeg {
    Param (
        [string]$hostArch,
        [bool]$isArm64
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

    $zlibPath = GetZlibPathByString -TargetArchitecture $arch
    $zlibPath = ConvertTo-MsysPath $zlibPath

    $config += " --enable-zlib"
    $config += " --extra-cflags=`"-I$zlibPath`""
    $config += " --extra-ldflags=`"-LIBPATH:$zlibPath`""

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

    $result = InstallFfmpeg -config $config -buildSystem $buildSystem -msystem "MSYS" -toolchain "msvc" -ffmpegDirEnvVar $ffmpegDirEnvVar -shared $true

    if ($result) {
        # As ffmpeg build system creates lib*.a file we have to rename them to *.lib files to be recognized by WIN32
        Write-Host "Rename libraries lib*.a -> *.lib"
        try {
            $msvcDir = [System.Environment]::GetEnvironmentVariable($ffmpegDirEnvVar, [System.EnvironmentVariableTarget]::Machine)
            Get-ChildItem "$msvcDir\lib\lib*.a" | ForEach-Object {
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
