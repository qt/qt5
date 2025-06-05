#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script will build and install FFmpeg shared libs
set -ex

source "${BASH_SOURCE%/*}/../unix/ffmpeg-installation-utils.sh"

os="$1"
# Optional parameter to set output installation directory. Useful for local builds.
target_install_dir_param="$2"
build_type=$(get_ffmpeg_build_type)
ffmpeg_source_dir=$(download_ffmpeg)

assert_envvar_is_populated_dir() {
    local envvar="$1"
    local value="${!envvar}"
    if [ -z "$value" ] || [ ! -d "$value" ] || [ -z "$(find "$value" -mindepth 1 -type f | head -n 1)" ]; then
        echo "Environment variable '$envvar' is unset, not a directory, or the directory is empty."
        exit 1
    fi
}
assert_envvar_is_populated_dir "OPENSSL_ANDROID_HOME_DEFAULT"
assert_envvar_is_populated_dir "ANDROID_NDK_ROOT_DEFAULT"

build_ffmpeg_android() {
    local target_arch=$1
    local target_dir=$2

    sudo mkdir -p "$target_dir"

    local openssl_include="$OPENSSL_ANDROID_HOME_DEFAULT/include"
    local openssl_libs
    local libs_prefix
    local target_cpu
    local target_toolchain_arch

    if [ "$target_arch" == "x86_64" ]; then
        target_toolchain_arch="x86_64-linux-android"
        target_arch=x86_64
        target_cpu=x86-64
        openssl_libs="$OPENSSL_ANDROID_HOME_DEFAULT/x86_64"
        libs_prefix="_x86_64"
    elif [ "$target_arch" == "x86" ]; then
        target_toolchain_arch="i686-linux-android"
        target_arch=x86
        target_cpu=i686
        openssl_libs="$OPENSSL_ANDROID_HOME_DEFAULT/x86"
        libs_prefix="_x86"
    elif [ "$target_arch" == "arm64" ]; then
        target_toolchain_arch="aarch64-linux-android"
        target_arch=aarch64
        target_cpu=armv8-a
        openssl_libs="$OPENSSL_ANDROID_HOME_DEFAULT/arm64-v8a"
        libs_prefix="_arm64-v8a"
    fi

    ln -Ffs "${openssl_libs}/libcrypto_3.so" "${openssl_libs}/libcrypto.so"
    ln -Ffs "${openssl_libs}/libssl_3.so" "${openssl_libs}/libssl.so"

    local api_version=24

    local ndk_root=$ANDROID_NDK_ROOT_DEFAULT
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
    local ffmpeg_config_options

    ffmpeg_config_options=$(get_ffmpeg_config_options $build_type)
    ffmpeg_config_options+=" --enable-cross-compile --target-os=android --enable-jni --enable-mediacodec --enable-openssl --enable-pthreads --enable-neon --disable-asm --disable-indev=android_camera"
    ffmpeg_config_options+=" --arch=$target_arch --cpu=${target_cpu} --sysroot=${sysroot} --sysinclude=${sysroot}/usr/include/"
    ffmpeg_config_options+=" --cc=${cc} --cxx=${cxx} --ar=${ar} --ranlib=${ranlib}"
    ffmpeg_config_options+=" --extra-cflags=-I${openssl_include} --extra-ldflags=-L${openssl_libs}"

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
        sudo "${fix_dependencies}" "${target_dir}" "${libs_prefix}" "no"
    fi
}

if  [ "$os" == "android-x86" ]; then
    target_arch=x86
    target_dir="/usr/local/android/ffmpeg-x86"
    envvar="FFMPEG_DIR_ANDROID_X86"
elif  [ "$os" == "android-x86_64" ]; then
    target_arch=x86_64
    target_dir="/usr/local/android/ffmpeg-x86_64"
    envvar="FFMPEG_DIR_ANDROID_X86_64"
elif  [ "$os" == "android-arm64" ]; then
    target_arch=arm64
    target_dir="/usr/local/android/ffmpeg-arm64"
    envvar="FFMPEG_DIR_ANDROID_ARM64"
else
    >&2 echo "Unhandled android os param: $os"
    exit 1
fi

# If parameter is set, use it as the target output directory.
if [ ! -z $target_install_dir_param ]; then
  target_dir=$target_install_dir_param
fi

build_ffmpeg_android "$target_arch" "$target_dir"
set_ffmpeg_dir_env_var "$envvar" "$target_dir"
