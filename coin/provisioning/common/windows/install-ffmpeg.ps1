# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script will install FFmpeg for all supported build variants.

. "$PSScriptRoot\install-ffmpeg-common.ps1"
. "$PSScriptRoot\install-ffmpeg-mingw.ps1"
. "$PSScriptRoot\install-ffmpeg-llvm-mingw.ps1"
. "$PSScriptRoot\install-ffmpeg-msvc.ps1"
. "$PSScriptRoot\install-ffmpeg-android.ps1"

GetFfmpegSource

function InstallFfmpegsAMD64 {
    $hostArch = "amd64"
    $mingwRes = InstallMingwFfmpeg
    $llvmMingwRes = InstallLlvmMingwFfmpeg
    if ($env:ANDROID_NDK_ROOT_LATEST) {
        Write-Host "Install FFmpeg using latest supported Android NDK"
        $androidArmV7Res = InstallAndroidArmv7 -ndk_root $env:ANDROID_NDK_ROOT_LATEST -ffmpeg_dir_android_envvar_name "FFMPEG_DIR_ANDROID_ARMV7_NDK_LATEST" -ndk_version "latest" -android_openssl_path $env:OPENSSL_ANDROID_HOME_LATEST -android_page_size "use_4kb_page_size"
    } else {
        throw "Error: env.var ANDROID_NDK_ROOT_LATEST is not set for FFmpeg"
    }
    if ($env:ANDROID_NDK_ROOT_NIGHTLY1) {
        Write-Host "Install FFmpeg using older Android NDK for nightly1"
        InstallAndroidArmv7 -ndk_root $env:ANDROID_NDK_ROOT_NIGHTLY1 -ffmpeg_dir_android_envvar_name "FFMPEG_DIR_ANDROID_ARMV7_NDK_NIGHTLY1" -ndk_version "nightly1" -android_openssl_path $env:OPENSSL_ANDROID_HOME_NIGHTLY1
    }
    if ($env:ANDROID_NDK_ROOT_NIGHTLY2) {
        Write-Host "Install FFmpeg using older Android NDK for nightly2"
        InstallAndroidArmv7 -ndk_root $env:ANDROID_NDK_ROOT_NIGHTLY2 -ffmpeg_dir_android_envvar_name "FFMPEG_DIR_ANDROID_ARMV7_NDK_NIGHTLY2" -ndk_version "nightly2" -android_openssl_path $env:OPENSSL_ANDROID_HOME_NIGHTLY2
    }
    try {
        $msvcRes = InstallMsvcFfmpeg -hostArch $hostArch -isArm64 $false
    } catch {
        Write-Host "Failed to build FFmpeg for msvc: $_"
        $msvcRes = $false
    }
    $msvcArm64Res = InstallMsvcFfmpeg -hostArch $hostArch -isArm64 $true

    Write-Host "FFmpeg installation results:"
    Write-Host "  mingw:" $(if ($mingwRes) { "OK" } else { "FAIL" })
    Write-Host "  llvm-mingw:" $(if ($llvmMingwRes) { "OK" } else { "FAIL" })
    Write-Host "  android-armv7:" $(if ($androidArmV7Res) { "OK" } else { "FAIL" })
    Write-Host "  msvc:" $(if ($msvcRes) { "OK" } else { "FAIL" })
    Write-Host "  msvc-arm64:" $(if ($msvcArm64Res) { "OK" } else { "FAIL" })

    exit $(if ($mingwRes -and $msvcRes -and $msvcArm64Res -and $llvmMingwRes -and $androidArmV7Res) { 0 } else { 1 })
}

function InstallFfmpegsARM64 {
    $hostArch = "arm64"
    $msvcArm64Res = InstallMsvcFfmpeg -hostArch $hostArch -isArm64 $true

    Write-Host "FFmpeg installation results:"
    Write-Host "  msvc-arm64:" $(if ($msvcArm64Res) { "OK" } else { "FAIL" })

    exit $(if ($msvcArm64Res) { 0 } else { 1 })
}

$cpu_arch = Get-CpuArchitecture
switch ($cpu_arch) {
    arm64 {
        InstallFfmpegsARM64
        Break
    }
    x64 {
        InstallFfmpegsAMD64
        Break
    }
    default {
        throw "Unknown architecture $cpu_arch"
    }
}
