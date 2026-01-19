#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script will build FFmpeg libraries for Android

usage() {
    cat <<EOF
Usage: $(basename "$0") --abi <abi> --ndk <dir> --openssl <dir> --page-size <size> --output <dir>

Build FFmpeg libraries for Android.

Options:
  --abi <abi>           Target Android ABI. One of: arm64, arm32, x86, x86_64.
  --ndk <dir>           Path to the Android NDK root.
  --openssl <dir>       Path to the OpenSSL for Android root.
  --page-size <size>    One of: 4kb, 16kb.
  --output <dir>        Directory to install FFmpeg into.
  -h, --help            Show this help and exit.

Example:
  $(basename "$0") --abi arm64 --ndk /path/to/ndk --openssl /path/to/openssl \\
      --page-size 16kb --output /path/to/output
EOF
}

abi=""
ndk_root=""
openssl_root=""
page_size=""
target_dir=""

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --abi|--ndk|--openssl|--page-size|--output)
            if [ $# -lt 2 ]; then
                echo "Error: option '$1' requires a value." >&2
                exit 2
            fi
            case "$1" in
                --abi) abi="$2" ;;
                --ndk) ndk_root="$2" ;;
                --openssl) openssl_root="$2" ;;
                --page-size) page_size="$2" ;;
                --output) target_dir="$2" ;;
            esac
            shift
            ;;
        *)
            echo "Error: unknown argument '$1'." >&2
            echo "" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

set -eux

source "${BASH_SOURCE%/*}/../unix/ffmpeg-installation-utils.sh"

is_populated_dir() {
    local value="$1"
    [ -n "$value" ] || return 1
    [ -d "$value" ] || return 1
    find "$value" -mindepth 1 -maxdepth 1 -print -quit >/dev/null 2>&1 || return 1
}

case "$abi" in
    arm64|arm32|x86|x86_64)
        ;;
    *)
        echo "Error: --abi must be one of: arm64, arm32, x86, x86_64. Got: '$abi'" >&2
        exit 1
        ;;
esac

if ! is_populated_dir "$ndk_root"; then
    echo "Error: --ndk '$ndk_root' is not a populated directory." >&2
    exit 1
fi

if ! is_populated_dir "$openssl_root"; then
    echo "Error: --openssl '$openssl_root' is not a populated directory." >&2
    exit 1
fi

if [ "$page_size" != "16kb" ] && [ "$page_size" != "4kb" ]; then
    echo "Error: --page-size must be '4kb' or '16kb'. Got: '$page_size'" >&2
    exit 1
fi

if [ -z "$target_dir" ]; then
    echo "Error: --output must be set." >&2
    exit 1
fi

build_type=$(get_ffmpeg_build_type)
ffmpeg_source_dir=$(download_ffmpeg)

build_ffmpeg_android() {
    local target_dir=$1

    sudo mkdir -p "$target_dir"

    local openssl_include="$openssl_root/include"
    local target_arch
    local openssl_libs
    local libs_prefix
    local target_cpu
    local target_toolchain_arch

    if [ "$abi" == "x86" ]; then
        target_toolchain_arch="i686-linux-android"
        target_arch=x86
        target_cpu=i686
        openssl_libs="$openssl_root/x86"
        libs_prefix="_x86"
    elif [ "$abi" == "x86_64" ]; then
        target_toolchain_arch="x86_64-linux-android"
        target_arch=x86_64
        target_cpu=x86-64
        openssl_libs="$openssl_root/x86_64"
        libs_prefix="_x86_64"
    elif [ "$abi" == "arm32" ]; then
        target_toolchain_arch="armv7a-linux-androideabi"
        target_arch=arm
        target_cpu=armv7-a
        openssl_libs="$openssl_root/armeabi-v7a"
        libs_prefix="_arm32-v7a"
    elif [ "$abi" == "arm64" ]; then
        target_toolchain_arch="aarch64-linux-android"
        target_arch=aarch64
        target_cpu=armv8-a
        openssl_libs="$openssl_root/arm64-v8a"
        libs_prefix="_arm64-v8a"
    else
        >&2 echo "Unhandled android abi param: $abi"
        exit 1
    fi

    ln -Ffs "${openssl_libs}/libcrypto_3.so" "${openssl_libs}/libcrypto.so"
    ln -Ffs "${openssl_libs}/libssl_3.so" "${openssl_libs}/libssl.so"

    local api_version=24

    local ndk_host
    if uname -a |grep -q "Darwin"; then
        ndk_host=darwin-x86_64
    else
        ndk_host=linux-x86_64
    fi

    local toolchain=${ndk_root}/toolchains/llvm/prebuilt/${ndk_host}
    local toolchain_bin=${toolchain}/bin
    local sysroot=${toolchain}/sysroot
    local cxx=${toolchain_bin}/${target_toolchain_arch}${api_version}-clang++
    local cc=${toolchain_bin}/${target_toolchain_arch}${api_version}-clang
    local ar=${toolchain_bin}/llvm-ar
    local ranlib=${toolchain_bin}/llvm-ranlib
    local strip=${toolchain_bin}/llvm-strip
    local ffmpeg_config_options

    ffmpeg_config_options=$(get_ffmpeg_config_options $build_type)
    ffmpeg_config_options+=" --enable-cross-compile --target-os=android --enable-jni --enable-mediacodec --enable-openssl --enable-pthreads --enable-neon --disable-asm --disable-indev=android_camera"
    ffmpeg_config_options+=" --arch=$target_arch --cpu=${target_cpu} --sysroot=${sysroot} --sysinclude=${sysroot}/usr/include/"
    ffmpeg_config_options+=" --cc=${cc} --cxx=${cxx} --ar=${ar} --ranlib=${ranlib} --strip=${strip}"
    ffmpeg_config_options+=" --extra-cflags=-I${openssl_include} --extra-ldflags=-L${openssl_libs}"
    if [ "$page_size" == "16kb" ]; then
        ffmpeg_config_options+=" --extra-ldflags=-Wl,-z,max-page-size=16384"
        echo "FFmpeg Android using 16KB page sizes"
    elif [ "$page_size" == "4kb" ]; then
        echo "FFmpeg Android using 4KB page sizes"
    fi
    local build_dir="$ffmpeg_source_dir/build_android/$target_arch"
    mkdir -p "$build_dir"
    pushd "$build_dir"

    # shellcheck disable=SC2086
    sudo "$ffmpeg_source_dir/configure" $ffmpeg_config_options --prefix="$target_dir"
    # shellcheck disable=

    sudo make install -j4

    popd

    rm -f "${openssl_libs}/libcrypto.so"
    rm -f "${openssl_libs}/libssl.so"

    if [[ "$build_type" == "shared" ]]; then
        local fix_dependencies="${BASH_SOURCE%/*}/../shared/fix_ffmpeg_dependencies.sh"

        local page_size_arg=""
        if [ "$page_size" == "16kb" ]; then
            page_size_arg="16384"
        fi
        local set_rpath_arg="no"
        local readelf_path_arg="${toolchain_bin}/llvm-readelf"
        sudo "$fix_dependencies" \
            "$target_dir" \
            "$libs_prefix" \
            "$set_rpath_arg" \
            "$page_size_arg" \
            "$readelf_path_arg"
    fi
}

build_ffmpeg_android "$target_dir"
