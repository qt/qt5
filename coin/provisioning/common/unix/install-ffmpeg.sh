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

function SourceEnvVar {
    echo "Source environment variables file"
    if [ uname -a | grep -q "Ubuntu" ];
    then
        if [ lsb_release -a | grep "Ubuntu 22.04" ];
        then source ~/.bashrc
        else source ~/.profile
        fi
    else
        source ~/.bashrc
        source ~/.zshrc
    fi
}

if [ "$os" == "android" ];
then
version="f0d2ed135c3602670b56a95e0346487730317407"
url_public="https://github.com/FFmpeg/FFmpeg/archive/$version.tar.gz"
sha1="a429060d07b6d84c849a68741f816a7e91447d12"
else
version="n5.1"
url_public="https://github.com/FFmpeg/FFmpeg/archive/refs/tags/$version.tar.gz"
sha1="1d4283c5ff9e02378893168f55b8672bb30b9176"
fi

url_cached="http://ci-files01-hki.intra.qt.io/input/ffmpeg/$version.tar.gz"
ffmpeg_name="FFmpeg-$version"

target_dir="$HOME"
app_prefix=""
ffmpeg_source_dir="$target_dir/$ffmpeg_name"

if [ ! -d "$ffmpeg_source_dir" ];
then
   InstallFromCompressedFileFromURL "$url_cached" "$url_public" "$sha1" "$target_dir" "$app_prefix"
fi

ffmpeg_config_options=$(cat "${BASH_SOURCE%/*}/../shared/ffmpeg_config_options.txt")


build_ffmpeg() {
  local arch="$1"
  local prefix="$2"
  local build_dir="$ffmpeg_source_dir/build/$arch"
  mkdir -p "$build_dir"
  pushd "$build_dir"

  if [ -z  "$prefix" ]
  then prefix="/usr/local/$ffmpeg_name"
  fi

  # android configures its own toolchain, it does not use the system clang
  if [ -n "$arch" ] && [ "$os" != "android" ]
  then cc="clang -arch $arch"
  fi

  if [ -n "$arch" ]
  then $ffmpeg_source_dir/configure $ffmpeg_config_options --prefix="$prefix" --enable-cross-compile --arch=$arch --cc="$cc"
  else $ffmpeg_source_dir/configure $ffmpeg_config_options --prefix="$prefix"
  fi
  make install DESTDIR=$build_dir/installed -j4
  popd
}

build_ffmpeg_android() {
  SourceEnvVar
  target_arch=$1
  target_dir=$2

  if [ "$target_arch" == "x86_64" ];
  then
    #emulador on CI is x86_64
    target_toolchain_arch="x86_64-linux-android"
    target_arch=x86_64
    target_cpu=x86_64
  else
    #emulador on CI is x86
    target_toolchain_arch="i686-linux-android"
    target_arch=x86
    target_cpu=i686
  fi

  api_version=24

  toolchain=${ANDROID_NDK_ROOT_DEFAULT}/toolchains/llvm/prebuilt/${ANDROID_NDK_HOST}
  toolchain_bin=${toolchain}/bin
  sysroot=${toolchain}/sysroot
  cxx=${toolchain_bin}/${target_toolchain_arch}${api_version}-clang++
  cc=${toolchain_bin}/${target_toolchain_arch}${api_version}-clang

  ffmpeg_config_options+=" --disable-vulkan --target-os=android --enable-jni --enable-mediacodec --enable-pthreads --enable-neon --disable-asm --cpu=${target_cpu} --disable-indev=android_camera --sysroot=${sysroot} --sysinclude=${sysroot}/usr/include/ --cc=${cc} --cxx=${cxx}"
  build_ffmpeg ${target_arch} ${target_dir}
}

if [ "$os" == "linux" ]; then
  build_ffmpeg
  sudo mv "$ffmpeg_source_dir/build/installed/usr/local/$ffmpeg_name" "/usr/local"
  SetEnvVar "FFMPEG_DIR" "/usr/local/$ffmpeg_name"

elif [ "$os" == "macos" ]; then
  brew install yasm
  export MACOSX_DEPLOYMENT_TARGET=11
  build_ffmpeg
  sudo mv "$ffmpeg_source_dir/build/installed/usr/local/$ffmpeg_name" "/usr/local"
  SetEnvVar "FFMPEG_DIR" "/usr/local/$ffmpeg_name"

elif [ "$os" == "macos-universal" ]; then
  brew install yasm
  export MACOSX_DEPLOYMENT_TARGET=11
  build_ffmpeg "arm64"
  build_ffmpeg "x86_64"

  sudo "${BASH_SOURCE%/*}/../macos/makeuniversal.sh" "$ffmpeg_source_dir/build/arm64/installed" "$ffmpeg_source_dir/build/x86_64/installed"
  SetEnvVar "FFMPEG_DIR" "/usr/local/$ffmpeg_name"

elif  [ "$os" == "android" ]; then

  SourceEnvVar

  url_cached=""
  url_public=""
  sha1=""

  #get emulator target arch
  if [ "$ANDROID_EMULATOR" == *"x86_64"* ];
  then
    target_arch=x86_64
    sha1="0241fd483c16f4ce53206b911214b06854cdef9d"
    url_cached="http://ci-files01-hki.intra.qt.io/input/ffmpeg/android-ffmpeg-x86_64.zip"
    target_dir="/opt/android/$ffmpeg_name/ffmpeg-x86_64"
  else
    target_arch=x86
    url_cached="http://ci-files01-hki.intra.qt.io/input/ffmpeg/android-ffmpeg-x86.zip"
    sha1="8b254e31411a350edb581bb30e31401866abbe7d"
    target_dir="/opt/android/$ffmpeg_name/ffmpeg-x86"
  fi

  app_prefix=""

  #try install a pre-build
  InstallFromCompressedFileFromURL "$url_cached" "$url_public" "$sha1" "$target_dir" "$app_prefix"

  #if could not install pre-build, build it
  if [ ! -d "$target_dir" ];
  then build_ffmpeg_android "$target_arch" "$target_dir"
  fi

  #set the var to use in yaml
  SetEnvVar "FFMPEG_DIR_ANDROID" "$target_dir"
fi

