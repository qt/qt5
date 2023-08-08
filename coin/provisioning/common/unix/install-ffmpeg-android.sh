#!/usr/bin/env bash

############################################################################
##
## Copyright (C) 2022 The Qt Company Ltd.
## Contact: https://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see https://www.qt.io/terms-conditions. For further
## information use the contact form at https://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 3 as published by the Free Software
## Foundation and appearing in the file LICENSE.LGPL3 included in the
## packaging of this file. Please review the following information to
## ensure the GNU Lesser General Public License version 3 requirements
## will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 2.0 or (at your option) the GNU General
## Public license version 3 or any later version approved by the KDE Free
## Qt Foundation. The licenses are as published by the Free Software
## Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
## included in the packaging of this file. Please review the following
## information to ensure the GNU General Public License requirements will
## be met: https://www.gnu.org/licenses/gpl-2.0.html and
## https://www.gnu.org/licenses/gpl-3.0.html.
##
## $QT_END_LICENSE$
##
#############################################################################

# This script will build and install FFmpeg static libs
set -ex
os="$1"

# shellcheck source=../unix/InstallFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../unix/InstallFromCompressedFileFromURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

version="n6.0"
url_public="https://github.com/FFmpeg/FFmpeg/archive/refs/tags/$version.tar.gz"
sha1="78435ec71cc2227017a99c030e858719b8c7c74d"
url_cached="http://ci-files01-hki.intra.qt.io/input/ffmpeg/$version.tar.gz"
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

  sudo mkdir -p "$target_dir"

  if [ "$target_arch" == "x86_64" ]; then
    target_toolchain_arch="x86_64-linux-android"
    target_arch=x86_64
    target_cpu=x86_64
  elif [ "$target_arch" == "x86" ]; then
    target_toolchain_arch="i686-linux-android"
    target_arch=x86
    target_cpu=i686
  elif [ "$target_arch" == "arm64" ]; then
    target_toolchain_arch="aarch64-linux-android"
    target_arch=aarch64
    target_cpu=armv8-a
  fi

  api_version=24

  ndk_root=/opt/android/android-ndk-r25b
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
  ld=${toolchain_bin}/ld
  ar=${toolchain_bin}/llvm-ar
  ranlib=${toolchain_bin}/llvm-ranlib
  nm=${toolchain_bin}/llvm-nm
  strip=${toolchain_bin}/llvm-strip

  ffmpeg_config_options=$(cat "${BASH_SOURCE%/*}/../shared/ffmpeg_config_options.txt")
  ffmpeg_config_options+=" --enable-cross-compile --target-os=android --enable-jni --enable-mediacodec --enable-pthreads --enable-neon --disable-asm --disable-indev=android_camera"
  ffmpeg_config_options+=" --arch=$target_arch --cpu=${target_cpu} --sysroot=${sysroot} --sysinclude=${sysroot}/usr/include/"
  ffmpeg_config_options+=" --cc=${cc} --cxx=${cxx} --ar=${ar} --ranlib=${ranlib}"

  local build_dir="$ffmpeg_source_dir/build/$target_arch"
  sudo mkdir -p "$build_dir"
  pushd "$build_dir"

  sudo $ffmpeg_source_dir/configure $ffmpeg_config_options --prefix="$target_dir"

  sudo make install -j4
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

build_ffmpeg_android "$target_arch" "$target_dir"
