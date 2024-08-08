#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script will build and install FFmpeg shared libs
set -ex
os="$1"

# shellcheck source=../unix/InstallFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../unix/InstallFromCompressedFileFromURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

version="n7.0.2"
url_public="https://github.com/FFmpeg/FFmpeg/archive/refs/tags/$version.tar.gz"
sha1="e017c72dd84a9bac1519eaa33c203b82dd850bc0"
url_cached="http://ci-files01-hki.ci.qt.io/input/ffmpeg/$version.tar.gz"
ffmpeg_name="FFmpeg-$version"

target_dir="$HOME"
app_prefix=""
ffmpeg_source_dir="$target_dir/$ffmpeg_name"

if [ ! -d "$ffmpeg_source_dir" ];
then
   InstallFromCompressedFileFromURL "$url_cached" "$url_public" "$sha1" "$target_dir" "$app_prefix"
fi

build_ffmpeg_android() {

  target_arch=$1
  target_dir=$2
  shared="${3:-no}"

  sudo mkdir -p "$target_dir"

  openssl_include="$OPENSSL_ANDROID_HOME_DEFAULT/include"
  openssl_libs=""
  libs_prefix=""
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

  ln -s "${openssl_libs}/libcrypto_3.so" "${openssl_libs}/libcrypto.so"
  ln -s "${openssl_libs}/libssl_3.so" "${openssl_libs}/libssl.so"

  api_version=24

  ndk_root=$ANDROID_NDK_ROOT_DEFAULT
  if uname -a |grep -q "Darwin"; then
    ndk_host=darwin-x86_64
  else
    ndk_host=linux-x86_64
  fi

  toolchain=${ndk_root}/toolchains/llvm/prebuilt/${ndk_host}
  toolchain_bin=${toolchain}/bin
  sysroot=${toolchain}/sysroot
  cxx=${toolchain_bin}/${target_toolchain_arch}${api_version}-clang++
  cc=${toolchain_bin}/${target_toolchain_arch}${api_version}-clang
  ar=${toolchain_bin}/llvm-ar
  ranlib=${toolchain_bin}/llvm-ranlib

  ffmpeg_config_options=$(cat "${BASH_SOURCE%/*}/../shared/ffmpeg_config_options.txt")
  ffmpeg_config_options+=" --enable-cross-compile --target-os=android --enable-jni --enable-mediacodec --enable-openssl --enable-pthreads --enable-neon --disable-asm --disable-indev=android_camera"
  if [[ "$shared" == "yes" ]]; then
      ffmpeg_config_options+=" --enable-shared --disable-static"
  fi
  ffmpeg_config_options+=" --arch=$target_arch --cpu=${target_cpu} --sysroot=${sysroot} --sysinclude=${sysroot}/usr/include/"
  ffmpeg_config_options+=" --cc=${cc} --cxx=${cxx} --ar=${ar} --ranlib=${ranlib}"
  ffmpeg_config_options+=" --extra-cflags=-I${openssl_include} --extra-ldflags=-L${openssl_libs}"

  local build_dir="$ffmpeg_source_dir/build/$target_arch"
  sudo mkdir -p "$build_dir"
  pushd "$build_dir"

  # shellcheck disable=SC2086
  sudo "$ffmpeg_source_dir/configure" $ffmpeg_config_options --prefix="$target_dir"

  sudo make install -j4

  rm -f "${openssl_libs}/libcrypto.so"
  rm -f "${openssl_libs}/libssl.so"

  if [[ "$shared" == "yes" ]]; then
      fix_dependencies="${BASH_SOURCE%/*}/../shared/fix_ffmpeg_dependencies.sh"
      sudo "${fix_dependencies}" "${target_dir}" "${libs_prefix}" "no"
  fi

  popd
}

if  [ "$os" == "android-x86" ]; then
  target_arch=x86
  target_dir="/usr/local/android/ffmpeg-x86"

  SetEnvVar "FFMPEG_DIR_ANDROID_X86" "$target_dir"
elif  [ "$os" == "android-x86_64" ]; then
  target_arch=x86_64
  target_dir="/usr/local/android/ffmpeg-x86_64"

  SetEnvVar "FFMPEG_DIR_ANDROID_X86_64" "$target_dir"
elif  [ "$os" == "android-arm64" ]; then
  target_arch=arm64
  target_dir="/usr/local/android/ffmpeg-arm64"

  SetEnvVar "FFMPEG_DIR_ANDROID_ARM64" "$target_dir"
fi

build_ffmpeg_android "$target_arch" "$target_dir" "yes"
