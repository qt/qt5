# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install FFmpeg
$msys = "C:\Utils\msys64\usr\bin\bash"

$version = "n6.0"
$ffmpeg_name = "ffmpeg-" + $version;
$sha1 = "5DDDE739FF966A7EEE810D65D7290860A52709D7"

$url_cached = "http://ci-files01-hki.intra.qt.io/input/ffmpeg/" + $version + ".zip"
$url_public = "https://github.com/FFmpeg/FFmpeg/archive/refs/tags/" +$version + ".zip"
$download_location = "C:\Windows\Temp\" + $ffmpeg_name + ".zip"
$unzip_location = "C:\"

Write-Host "Fetching FFmpeg $version..."

Download $url_public $url_cached $download_location
Verify-Checksum $download_location $sha1
Extract-7Zip $download_location $unzip_location
Remove $download_location

$config = Get-Content "$PSScriptRoot\..\shared\ffmpeg_config_options.txt"
Write-Host "FFmpeg configuration $config"


function InstallFfmpeg {
    Param (
        [string]$buildSystem,
        [string]$msystem,
        [string]$additionalPath,
        [string]$ffmpegDirEnvVar,
        [string]$toolchain
    )

    Write-Host "Configure and compile ffmpeg for $buildSystem"

    $oldPath = $env:PATH

    if ($additionalPath) { $env:PATH = "$additionalPath;$env:PATH" }
    $env:MSYS2_PATH_TYPE = "inherit"
    $env:MSYSTEM = $msystem

    $cmd = "cd /c/$ffmpeg_name"
    $cmd += " && mkdir -p build/$buildSystem && cd build/$buildSystem"
    $cmd += " && ../../configure --prefix=installed $config"
    if ($toolchain) { $cmd += " --toolchain=$toolchain" }
    $cmd += " && make install -j"

    Write-Host "MSYS cmd:"
    Write-Host $cmd
    $buildResult = Start-Process -NoNewWindow -Wait -PassThru -ErrorAction Stop -FilePath "$msys" -ArgumentList ("-lc", "`"$cmd`"")

    $env:PATH = $oldPath

    if ($buildResult.ExitCode) {
        Write-Host "Failed to build ffmpeg for $buildSystem"
        return $false
    }

    Set-EnvironmentVariable $ffmpegDirEnvVar "C:\$ffmpeg_name\build\$buildSystem\installed"
    return $true
}

function InstallMingwFfmpeg {
    $mingwPath = [System.Environment]::GetEnvironmentVariable("MINGW1120", [System.EnvironmentVariableTarget]::Machine)
    return InstallFfmpeg -buildSystem "mingw" -msystem "MINGW" -additionalPath "$mingwPath\bin" -ffmpegDirEnvVar "FFMPEG_DIR_MINGW"
}


function InstallMsvcFfmpeg {
    $result = EnterVSDevShell
    if (-Not $result) {
        return $false
    }

    $result = InstallFfmpeg -buildSystem "msvc" -msystem "MSYS" -toolchain "msvc" -ffmpegDirEnvVar "FFMPEG_DIR_MSVC"

    if ($result) {
        # As ffmpeg build system creates lib*.a file we have to rename them to *.lib files to be recognized by WIN32
        Write-Host "Rename libraries lib*.a -> *.lib"
        try {
            $msvcDir = [System.Environment]::GetEnvironmentVariable("FFMPEG_DIR_MSVC", [System.EnvironmentVariableTarget]::Machine)
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


function InstallLlvmMingwFfmpeg {
    return InstallFfmpeg -buildSystem "llvm-mingw" -msystem "CLANG64" -ffmpegDirEnvVar "FFMPEG_DIR_LLVM_MINGW" -additionalPath "C:\llvm-mingw\bin"
}

function InstallAndroidArmv7 {

    $target_toolchain_arch="armv7a-linux-androideabi"
    $target_arch="armv7-a"
    $target_cpu="armv7-a"
    $api_version="24"

    $ndkVersionLatest = "r25b"
    $ndkFolderLatest = "/c/Utils/Android/android-ndk-$ndkVersionLatest"

    $toolchain="${ndkFolderLatest}/toolchains/llvm/prebuilt/windows-x86_64"
    $toolchain_bin="${toolchain}/bin"
    $sysroot="${toolchain}/sysroot"
    $cxx="${toolchain_bin}/${target_toolchain_arch}${api_version}-clang++"
    $cc="${toolchain_bin}/${target_toolchain_arch}${api_version}-clang"
    $ld="${toolchain_bin}/ld.exe"
    $ar="${toolchain_bin}/llvm-ar.exe"
    $ranlib="${toolchain_bin}/llvm-ranlib.exe"
    $nm="${toolchain_bin}/llvm-nm.exe"
    $strip="${toolchain_bin}/llvm-strip.exe"

    $config = Get-Content "$PSScriptRoot\..\shared\ffmpeg_config_options.txt"
    $config += " --enable-cross-compile --target-os=android --enable-jni --enable-mediacodec --enable-pthreads --enable-neon --disable-asm --disable-indev=android_camera"
    $config += " --arch=$target_arch --cpu=${target_cpu} --sysroot=${sysroot} --sysinclude=${sysroot}/usr/include/"
    $config += " --cc=${cc} --cxx=${cxx} --ar=${ar} --ranlib=${ranlib}"

    return InstallFfmpeg -buildSystem "android-arm" -msystem "ANDROID_CLANG" -ffmpegDirEnvVar "FFMPEG_DIR_ANDROID_ARMV7"
}

$mingwRes = InstallMingwFfmpeg
$msvcRes = InstallMsvcFfmpeg
$llvmMingwRes = InstallLlvmMingwFfmpeg
$androidArmV7Res = InstallAndroidArmv7

Write-Host "Ffmpeg installation results:"
Write-Host "  mingw:" $(if ($mingwRes) { "OK" } else { "FAIL" })
Write-Host "  msvc:" $(if ($msvcRes) { "OK" } else { "FAIL" })
Write-Host "  llvm-mingw:" $(if ($llvmMingwRes) { "OK" } else { "FAIL" })
Write-Host "  android-armv7:" $(if ($androidArmV7Res) { "OK" } else { "FAIL" })

exit $(if ($mingwRes -and $msvcRes -and $llvmMingwRes -and $androidArmV7Res) { 0 } else { 1 })
