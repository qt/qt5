# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"
. "$PSScriptRoot\zlib-helpers.ps1"

# This script will install FFmpeg
$msys = "C:\Utils\msys64\usr\bin\bash"

$version="n7.1.2"
$url_public="https://github.com/FFmpeg/FFmpeg/archive/refs/tags/$version.tar.gz"
$sha1="1e4e937facdbde15943dd093121836bf69f27c7c"
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

# Returns the absolute installation path of FFmpeg for this build
# variant. Returns a path that is compatible with MSYS.
#
# TODO: There is some code duplications here. Make a helper function
# that translates native Windows paths into MSYS compatible paths.
function ResolveFFmpegInstallDirMsys {
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

    return "/c/$ffmpeg_name/build/$buildSystem/$prefix"
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
        [string]$ndk_ver  # Optional param for installing each ffmpeg build with different Android NDK
    )

    Write-Host "Configure and compile FFmpeg for $buildSystem with configuration: $config"

    $oldPath = $env:PATH

    if ($additionalPath) {
        $env:PATH = "$additionalPath;$env:PATH"
    }
    $env:MSYS2_PATH_TYPE = "inherit"
    $env:MSYSTEM = $msystem

    if ($ndk_ver) {
        $installDir = ResolveFFmpegInstallDir -buildSystem $buildSystem -ndkVer $ndk_ver
        $installDirForMsys = ResolveFFmpegInstallDirMsys -buildSystem $buildSystem -ndkVer $ndk_ver
    } else {
        $installDir = ResolveFFmpegInstallDir -buildSystem $buildSystem
        $installDirForMsys = ResolveFFmpegInstallDirMsys -buildSystem $buildSystem
    }

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
    $buildResult = Start-Process -NoNewWindow -Wait -PassThru -ErrorAction Stop -FilePath "$msys" -ArgumentList ("-lc", "`"$cmd`"")

    $env:PATH = $oldPath

    if ($buildResult.ExitCode) {
        Write-Host "Failed to build FFmpeg for $buildSystem"
        return $false
    }

    Set-EnvironmentVariable $ffmpegDirEnvVar $installDir
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

    $zlibPath = GetZlibPathByString -TargetArchitecture $arch
    $zlibPath = $zlibPath -replace '\\', '/'

    $config += " --enable-zlib"
    $config += " --extra-cflags=`"-I$zlibPath`""
    $config += " --extra-ldflags=`"-LIBPATH:$zlibPath`""

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
    param (
        [string]$ndk_root,
        [string]$ffmpeg_dir_android_envvar_name,
        [string]$ndk_version,
        [string]$android_openssl_path,  # OpenSSL is built for Android using NDK, NDK versions for OpenSSL+FFmpeg should match
        [string]$android_page_size
    )
    $shared=$true
    $target_toolchain_arch="armv7a-linux-androideabi"
    $target_arch="armv7-a"
    $target_cpu="armv7-a"
    $api_version="24"

    $ndk_dir = $ndk_root -replace '\\', '/' -replace '^C:', '/c'

    $toolchain="${ndk_dir}/toolchains/llvm/prebuilt/windows-x86_64"
    $toolchain_bin="${toolchain}/bin"
    $sysroot="${toolchain}/sysroot"
    $cxx="${toolchain_bin}/${target_toolchain_arch}${api_version}-clang++"
    $cc="${toolchain_bin}/${target_toolchain_arch}${api_version}-clang"
    $ld="${toolchain_bin}/ld.exe"
    $ar="${toolchain_bin}/llvm-ar.exe"
    $ranlib="${toolchain_bin}/llvm-ranlib.exe"
    $nm="${toolchain_bin}/llvm-nm.exe"
    $strip="${toolchain_bin}/llvm-strip.exe"
    $openssl_path = $android_openssl_path.Replace("\", "/")

    Write-Host "Copying _3.so's to .so's"
    Copy-Item -Path ${openssl_path}/armeabi-v7a/libcrypto_3.so -Destination ${openssl_path}/armeabi-v7a/libcrypto.so
    Copy-Item -Path ${openssl_path}/armeabi-v7a/libssl_3.so -Destination ${openssl_path}/armeabi-v7a/libssl.so


    $config = GetFfmpegDefaultConfiguration
    $config += " --enable-cross-compile --target-os=android --enable-jni --enable-mediacodec --enable-openssl --enable-pthreads --enable-neon --disable-asm --disable-indev=android_camera"
    $config += " --arch=$target_arch --cpu=${target_cpu} --sysroot=${sysroot} --sysinclude=${sysroot}/usr/include/"
    $config += " --cc=${cc} --cxx=${cxx} --ar=${ar} --ranlib=${ranlib}"
    $config += " --extra-cflags=-I${android_openssl_path}/include --extra-ldflags=-L${android_openssl_path}/armeabi-v7a"
    $config += " --extra-cflags=-I${openssl_path}/include --extra-ldflags=-L${openssl_path}/armeabi-v7a"
    if ($android_page_size -eq "use_16kb_page_size"){
        $config += " --extra-ldflags=-Wl,-z,max-page-size=16384"
        Write-Host "FFmpeg Android using 16KB page sizes"
    } elseif ($android_page_size -eq "use_4kb_page_size") {
        Write-Host "FFmpeg Android using 4KB page sizes"
    } else {
        Write-Host "Error: FFmpeg Android page_size must be: use_16kb_page_size or: use_16kb_page_size got: $android_page_size"
        return false
    }

    $config += " --strip=$strip"

    $buildSystem = "android-arm"
    $result= InstallFfmpeg -config $config -buildSystem $buildSystem -msystem "ANDROID_CLANG" -ffmpegDirEnvVar $ffmpeg_dir_android_envvar_name -shared $shared -ndk_ver $ndk_version

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

    $installDirForMsys = ResolveFFmpegInstallDirMsys -buildSystem $buildSystem -ndkVer $ndk_version
    $command = "${PSScriptRoot}/../shared/fix_ffmpeg_dependencies.sh ${installDirForMsys} _armeabi-v7a no"
    $command = $command.Replace("\", "/")
    $patchResult = Start-Process -NoNewWindow -Wait -PassThru -ErrorAction Stop -FilePath $msys -ArgumentList ("-lc", "`"$command`"")
    if ($patchResult.ExitCode) {
        Write-Host "fix_ffmpeg_dependencies.sh did not finish successfully"
        return $false
    }

    return $result
}

function InstallFfmpegsAMD64 {
    $hostArch = "amd64"
    $mingwRes = InstallMingwFfmpeg
    $llvmMingwRes = InstallLlvmMingwFfmpeg
    if ($env:ANDROID_NDK_ROOT_LATEST) {
        Write-Host "Install ffmpeg using latest supported Android NDK"
        $androidArmV7Res = InstallAndroidArmv7 -ndk_root $env:ANDROID_NDK_ROOT_LATEST -ffmpeg_dir_android_envvar_name "FFMPEG_DIR_ANDROID_ARMV7_NDK_LATEST" -ndk_version "latest" -android_openssl_path $env:OPENSSL_ANDROID_HOME_LATEST -android_page_size "use_4kb_page_size"
    } else {
        throw "Error: env.var ANDROID_NDK_ROOT_LATEST is not set for FFmpeg"
    }
    if ($env:ANDROID_NDK_ROOT_NIGHTLY1) {
        Write-Host "Install ffmpeg using older Android NDK for nightly1"
        InstallAndroidArmv7 -ndk_root $env:ANDROID_NDK_ROOT_NIGHTLY1 -ffmpeg_dir_android_envvar_name "FFMPEG_DIR_ANDROID_ARMV7_NDK_NIGHTLY1" -ndk_version "nightly1" -android_openssl_path $env:OPENSSL_ANDROID_HOME_NIGHTLY1
    }
    if ($env:ANDROID_NDK_ROOT_NIGHTLY2) {
        Write-Host "Install ffmpeg using older Android NDK for nightly2"
        InstallAndroidArmv7 -ndk_root $env:ANDROID_NDK_ROOT_NIGHTLY2 -ffmpeg_dir_android_envvar_name "FFMPEG_DIR_ANDROID_ARMV7_NDK_NIGHTLY2" -ndk_version "nightly2" -android_openssl_path $env:OPENSSL_ANDROID_HOME_NIGHTLY2
    }
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
