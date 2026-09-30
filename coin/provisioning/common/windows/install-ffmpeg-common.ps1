# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Shared variables and helpers for the FFmpeg install scripts

. "$PSScriptRoot\helpers.ps1"

$msys = "C:\Utils\msys64\usr\bin\bash"

$version="9.0.2"
$url_public="https://ffmpeg.org/releases/ffmpeg-$version.tar.gz"
$sha1="40c70cddcdc2e32b1b0fad2c85915c9145532452"
$url_cached="http://ci-files01-hki.ci.qt.io/input/ffmpeg/ffmpeg-$version.tar.gz"
$ffmpeg_name="FFmpeg-n$version"

$download_location = "C:\Windows\Temp\$ffmpeg_name.tar.gz"
$unzip_location = "C:\"
$ffmpeg_source_dir = "C:\$ffmpeg_name"

# Downloads and extracts the FFmpeg source into $ffmpeg_source_dir.
function GetFfmpegSource {
    Write-Host "Fetching FFmpeg $version..."

    $extract_temp_dir = "C:\Windows\Temp\FFmpeg-extract-$([System.Guid]::NewGuid().ToString('N'))"

    try {
        New-Item -ItemType Directory -Path $extract_temp_dir -Force | Out-Null

        Download $url_public $url_cached $download_location
        Verify-Checksum $download_location $sha1
        Extract-tar_gz $download_location $extract_temp_dir

        $extracted_dirs = @(Get-ChildItem -Path $extract_temp_dir -Directory)
        if ($extracted_dirs.Count -ne 1) {
            throw "Expected exactly one directory in the FFmpeg archive, got: $($extracted_dirs.Name -join ', ')"
        }

        Remove $ffmpeg_source_dir
        Move-Item -Path $extracted_dirs[0].FullName -Destination $ffmpeg_source_dir
    } finally {
        Remove $download_location
        Remove $extract_temp_dir
    }
}

function GetFfmpegDefaultConfiguration {
    $defaultConfiguration = Get-Content "$PSScriptRoot\..\shared\ffmpeg_config_options.txt"
    Write-Host "FFmpeg default configuration: $defaultConfiguration"

    return $defaultConfiguration
}

# Returns the absolute installation path of FFmpeg for this build
# variant.
function ResolveFFmpegInstallDir {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$buildSystem,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$ndkVer
    )

    if ($ndkVer) {
        $prefix = "installed-ndk-$ndkVer"
    } else {
        $prefix = "installed"
    }

    return "C:\$ffmpeg_name\build\$buildSystem\$prefix"
}

function InstallFfmpeg {
    Param (
        [string]$config,
        [string]$buildSystem,
        [string]$msystem,
        [string]$additionalPath,
        [string]$ffmpegDirEnvVar,
        [string]$toolchain,
        [bool]$shared,
        [string]$ndk_ver,           # Optional param for installing each ffmpeg build with different Android NDK
        [string]$installDir,        # Optional override for where to install the build artifacts
        [string]$msysBash,          # Optional override for the MSYS bash executable
        [bool]$skipEnvVar = $false  # Optional:
                                    # Don't assign the FFmpeg dir environment variable.
                                    # Allows the function to run without elevated privileges.
    )

    Write-Host "Configure and compile FFmpeg for $buildSystem with configuration: $config"

    $bash = if ($msysBash) { $msysBash } else { $msys }

    $oldPath = $env:PATH

    if ($additionalPath) {
        $env:PATH = "$additionalPath;$env:PATH"
    }
    $env:MSYS2_PATH_TYPE = "inherit"
    $env:MSYSTEM = $msystem

    if (-not $installDir) {
        if ($ndk_ver) {
            $installDir = ResolveFFmpegInstallDir -buildSystem $buildSystem -ndkVer $ndk_ver
        } else {
            $installDir = ResolveFFmpegInstallDir -buildSystem $buildSystem
        }
    }
    $installDirForMsys = ConvertTo-MsysPath $installDir

    $cmd = "cd /c/$ffmpeg_name"
    $cmd += " && mkdir -p build/$buildSystem && cd build/$buildSystem"
    $cmd += " && ../../configure --prefix=$installDirForMsys $config"
    if ($toolchain) {
        $cmd += " --toolchain=$toolchain"
    }
    if ($shared) {
        $cmd += " --enable-shared --disable-static"
    }
    $cmd += " && make install -j"

    Write-Host "MSYS cmd:"
    Write-Host $cmd
    # Don't use Start-Process -Wait. It waits for the whole process tree, which hangs when
    # MSVC leaves detached helpers behind (e.g. vctip.exe). Wait for bash itself instead.
    $buildResult = Start-Process -NoNewWindow -PassThru -ErrorAction Stop -FilePath "$bash" -ArgumentList ("-lc", "`"$cmd`"")
    # Cache the process handle so ExitCode stays available after the process exits
    $null = $buildResult.Handle
    $buildResult.WaitForExit()

    $env:PATH = $oldPath

    if ($buildResult.ExitCode) {
        Write-Host "Failed to build FFmpeg for $buildSystem"
        return $false
    }

    if (-not $skipEnvVar) {
        Set-EnvironmentVariable $ffmpegDirEnvVar $installDir
    }
    return $true
}
