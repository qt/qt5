# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install FFmpeg
$msys = "C:\Utils\msys64\usr\bin\bash"

$version="n7.0.2"
$url_public="https://github.com/FFmpeg/FFmpeg/archive/refs/tags/$version.tar.gz"
$sha1="e017c72dd84a9bac1519eaa33c203b82dd850bc0"
$url_cached="http://ci-files01-hki.ci.qt.io/input/ffmpeg/$version.tar.gz"
$ffmpeg_name="FFmpeg-$version"

$download_location = "C:\Windows\Temp\$ffmpeg_name.tar.gz"
$unzip_location = "C:\"

Write-Host "Fetching FFmpeg $version..."

Download $url_public $url_cached $download_location
Verify-Checksum $download_location $sha1
Extract-tar_gz $download_location $unzip_location
Remove $download_location

function GetFfmpegDefaultConfiguration {
    $defaultConfiguration = Get-Content "$PSScriptRoot\..\shared\ffmpeg_config_options.txt"
    Write-Host "FFmpeg default configuration: $defaultConfiguration"

    return $defaultConfiguration
}

function InstallFfmpeg {
    Param (
        [string]$config,
        [string]$buildSystem,
        [string]$msystem,
        [string]$additionalPath,
        [string]$ffmpegDirEnvVar,
        [string]$toolchain,
        [bool]$shared
    )

    Write-Host "Configure and compile FFmpeg for $buildSystem with configuration: $config"

    $oldPath = $env:PATH

    if ($additionalPath) {
        $env:PATH = "$additionalPath;$env:PATH"
    }
    $env:MSYS2_PATH_TYPE = "inherit"
    $env:MSYSTEM = $msystem

    $cmd = "cd /c/$ffmpeg_name"
    $cmd += " && mkdir -p build/$buildSystem && cd build/$buildSystem"
    $cmd += " && ../../configure --prefix=installed $config"
    if ($toolchain) {
        $cmd += " --toolchain=$toolchain"
    }
    if ($shared) {
        $cmd += " --enable-shared --disable-static"
    }
    $cmd += " && make install -j"

    Write-Host "MSYS cmd:"
    Write-Host $cmd
    $buildResult = Start-Process -NoNewWindow -Wait -PassThru -ErrorAction Stop -FilePath "$msys" -ArgumentList ("-lc", "`"$cmd`"")

    $env:PATH = $oldPath

    if ($buildResult.ExitCode) {
        Write-Host "Failed to build FFmpeg for $buildSystem"
        return $false
    }

    Set-EnvironmentVariable $ffmpegDirEnvVar "C:\$ffmpeg_name\build\$buildSystem\installed"
    return $true
}

function InstallMingwFfmpeg {
    $config = GetFfmpegDefaultConfiguration
    $mingwPath = [System.Environment]::GetEnvironmentVariable("MINGW_PATH", [System.EnvironmentVariableTarget]::Machine)
    return InstallFfmpeg -config $config -buildSystem "mingw" -msystem "MINGW" -additionalPath "$mingwPath\bin" -ffmpegDirEnvVar "FFMPEG_DIR_MINGW" -shared $true
}


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

    $result = EnterVSDevShell -HostArch $hostArch -Arch $arch
    if (-Not $result) {
        return $false
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


function InstallLlvmMingwFfmpeg {
    $config = GetFfmpegDefaultConfiguration
    return InstallFfmpeg -config $config -buildSystem "llvm-mingw" -msystem "CLANG64" -ffmpegDirEnvVar "FFMPEG_DIR_LLVM_MINGW" -additionalPath "C:\llvm-mingw\bin" -shared $true
}

function InstallAndroidArmv7 {
    $shared=$true
    $target_toolchain_arch="armv7a-linux-androideabi"
    $target_arch="armv7-a"
    $target_cpu="armv7-a"
    $api_version="24"

    $ndkVersionLatest = "r26b"
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
    $openssl_path = [System.Environment]::GetEnvironmentVariable("OPENSSL_ANDROID_HOME_DEFAULT", [System.EnvironmentVariableTarget]::Machine)
    $openssl_path = $openssl_path.Replace("\", "/")

    New-Item -ItemType SymbolicLink -Path ${openssl_path}/armeabi-v7a/libcrypto.so -Target ${openssl_path}/armeabi-v7a/libcrypto_3.so
    New-Item -ItemType SymbolicLink -Path ${openssl_path}/armeabi-v7a/libssl.so -Target ${openssl_path}/armeabi-v7a/libssl_3.so

    $config = GetFfmpegDefaultConfiguration
    $config += " --enable-cross-compile --target-os=android --enable-jni --enable-mediacodec --enable-openssl --enable-pthreads --enable-neon --disable-asm --disable-indev=android_camera"
    $config += " --arch=$target_arch --cpu=${target_cpu} --sysroot=${sysroot} --sysinclude=${sysroot}/usr/include/"
    $config += " --cc=${cc} --cxx=${cxx} --ar=${ar} --ranlib=${ranlib}"
    $config += " --extra-cflags=-I$envOPENSSL_ANDROID_HOME_DEFAULT/include --extra-ldflags=-L$env:OPENSSL_ANDROID_HOME_DEFAULT/armeabi-v7a"
    $config += " --extra-cflags=-I${openssl_path}/include --extra-ldflags=-L${openssl_path}/armeabi-v7a"
    $config += " --strip=$strip"


    $result= InstallFfmpeg -config $config -buildSystem "android-arm" -msystem "ANDROID_CLANG" -ffmpegDirEnvVar "FFMPEG_DIR_ANDROID_ARMV7" -shared $shared

    Remove-Item -Path ${openssl_path}/armeabi-v7a/libcrypto.so
    Remove-Item -Path ${openssl_path}/armeabi-v7a/libssl.so

    if (-not $shared) {
        return $result
    }

    # For Shared ffmpeg we need to change dependencies to stubs
    Start-Process -NoNewWindow -Wait -PassThru -ErrorAction Stop -FilePath $msys -ArgumentList ("-lc", "`"pacman -Sy --noconfirm binutils`"")
    Start-Process -NoNewWindow -Wait -PassThru -ErrorAction Stop -FilePath $msys -ArgumentList ("-lc", "`"pacman -Sy --noconfirm autoconf`"")
    Start-Process -NoNewWindow -Wait -PassThru -ErrorAction Stop -FilePath $msys -ArgumentList ("-lc", "`"pacman -Sy --noconfirm automake`"")
    Start-Process -NoNewWindow -Wait -PassThru -ErrorAction Stop -FilePath $msys -ArgumentList ("-lc", "`"pacman -Sy --noconfirm libtool`"")

    $patchelf_sha1 = "DDD46A2E2A16A308245C008721D877455B23BBA8"
    $patchelf_sources = "https://ci-files01-hki.ci.qt.io/input/android/patchelf/0.17.2.tar.gz"
    $patchelf_download_location = "C:\Windows\Temp\0.17.2.tar.gz"

    Invoke-WebRequest -UseBasicParsing $patchelf_sources -OutFile $patchelf_download_location
    Verify-Checksum $patchelf_download_location $patchelf_sha1
    Extract-tar_gz $patchelf_download_location $unzip_location
    Remove $patchelf_download_location

    Start-Process -NoNewWindow -Wait -PassThru -ErrorAction Stop -FilePath $msys -ArgumentList ("-lc", "`"cd C:/patchelf-0.17.2 && ./bootstrap.sh && ./configure && make install`"")

    $command = "${PSScriptRoot}/../shared/fix_ffmpeg_dependencies.sh C:/${ffmpeg_name}/build/android-arm/installed/ _armeabi-v7a no"
    $command = $command.Replace("\", "/")
    Start-Process -NoNewWindow -Wait -PassThru -ErrorAction Stop -FilePath $msys -ArgumentList ("-lc", "`"$command`"")

    return $result
}

function InstallFfmpegsAMD64 {
    $hostArch = "amd64"
    $mingwRes = InstallMingwFfmpeg
    $llvmMingwRes = InstallLlvmMingwFfmpeg
    $androidArmV7Res = InstallAndroidArmv7
    $msvcRes = InstallMsvcFfmpeg -hostArch $hostArch -isArm64 $false
    $msvcArm64Res = InstallMsvcFfmpeg -hostArch $hostArch -isArm64 $true

    Write-Host "Ffmpeg installation results:"
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

    Write-Host "Ffmpeg installation results:"
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
