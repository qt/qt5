# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\install-ffmpeg-common.ps1"

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

    $ndk_dir = ConvertTo-MsysPath $ndk_root

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

    Write-Host "Copying _3.so's to .so's"
    Copy-Item -Path ${android_openssl_path}/armeabi-v7a/libcrypto_3.so -Destination ${android_openssl_path}/armeabi-v7a/libcrypto.so
    Copy-Item -Path ${android_openssl_path}/armeabi-v7a/libssl_3.so -Destination ${android_openssl_path}/armeabi-v7a/libssl.so

    $android_openssl_path_msys = ConvertTo-MsysPath $android_openssl_path

    $config = GetFfmpegDefaultConfiguration
    $config += " --enable-cross-compile --target-os=android --enable-jni --enable-mediacodec --enable-openssl --enable-pthreads --enable-neon --disable-asm --disable-indev=android_camera"
    $config += " --arch=$target_arch --cpu=${target_cpu} --sysroot=${sysroot} --sysinclude=${sysroot}/usr/include/"
    $config += " --cc=${cc} --cxx=${cxx} --ar=${ar} --ranlib=${ranlib}"
    $config += " --extra-cflags=-I${android_openssl_path_msys}/include --extra-ldflags=-L${android_openssl_path_msys}/armeabi-v7a"
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

    Remove-Item -Path ${android_openssl_path}/armeabi-v7a/libcrypto.so
    Remove-Item -Path ${android_openssl_path}/armeabi-v7a/libssl.so

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

    try {
        Invoke-WebRequest -UseBasicParsing $patchelf_sources -OutFile $patchelf_download_location
        Verify-Checksum $patchelf_download_location $patchelf_sha1
        Extract-tar_gz $patchelf_download_location $unzip_location
        Remove $patchelf_download_location
    } catch {
        Write-Host "Error grabbing sources when installing patchelf:"
        Write-Host $_
        return $false
    }

    Start-Process -NoNewWindow -Wait -PassThru -ErrorAction Stop -FilePath $msys -ArgumentList ("-lc", "`"cd C:/patchelf-0.17.2 && ./bootstrap.sh && ./configure && make install`"")

    $installDir = ResolveFFmpegInstallDir -buildSystem $buildSystem -ndkVer $ndk_version
    $installDirForMsys = ConvertTo-MsysPath $installDir
    $command = "${PSScriptRoot}/../shared/fix_ffmpeg_dependencies.sh ${installDirForMsys} _armeabi-v7a no"
    $command = $command.Replace("\", "/")
    $patchResult = Start-Process -NoNewWindow -Wait -PassThru -ErrorAction Stop -FilePath $msys -ArgumentList ("-lc", "`"$command`"")
    if ($patchResult.ExitCode) {
        Write-Host "fix_ffmpeg_dependencies.sh did not finish successfully"
        return $false
    }

    return $result
}
