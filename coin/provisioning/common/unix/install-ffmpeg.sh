#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script will build and install FFmpeg static libs
set -ex
os="$1"

# shellcheck source=../unix/InstallFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../unix/InstallFromCompressedFileFromURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

# Commit c5039e158d20e85d4d8a2dee3160533d627b839a is the latest one in 6.0 branch. 
# When using the latest commit we will also get fix for https://fftrac-bg.ffmpeg.org/ticket/10405
# Should be changed to official release as soon as possible!
version="c5039e158d20e85d4d8a2dee3160533d627b839a"
url_public="https://github.com/FFmpeg/FFmpeg/archive/$version.tar.gz"
sha1="4e13a26d3be7ac4d69201a6aa0accd734b24b3c4"
url_cached="http://ci-files01-hki.ci.qt.io/input/ffmpeg/$version.tar.gz"
ffmpeg_name="FFmpeg-$version"

target_dir="$HOME"
app_prefix=""
ffmpeg_source_dir="$target_dir/$ffmpeg_name"

if [ ! -d "$ffmpeg_source_dir" ];
then
   InstallFromCompressedFileFromURL "$url_cached" "$url_public" "$sha1" "$target_dir" "$app_prefix"
fi

ffmpeg_config_options=$(cat "${BASH_SOURCE%/*}/../shared/ffmpeg_config_options.txt")

install_ff_nvcodec_headers() {
  nv_codec_version="11.1" # use 11.1 to ensure compatibility with 470 nvidia drivers; might be upated to 12.0
  nv_codec_url_public="https://github.com/FFmpeg/nv-codec-headers/archive/refs/heads/sdk/$nv_codec_version.zip"
  nv_codec_url_cached="http://ci-files01-hki.ci.qt.io/input/ffmpeg/nv-codec-headers/nv-codec-headers-sdk-$nv_codec_version.zip"
  nv_codec_sha1="ceb4966ab01b2e41f02074675a8ac5b331bf603e"
  #nv_codec_sha1="4f30539f8dd31945da4c3da32e66022f9ca59c08" // 12.0
  nv_codec_dir="$target_dir/nv-codec-headers-sdk-$nv_codec_version"
  if [ ! -d  "$nv_codec_dir" ];
  then
    InstallFromCompressedFileFromURL "$nv_codec_url_cached" "$nv_codec_url_public" "$nv_codec_sha1" "$target_dir" ""
  fi

  sudo make -C "$nv_codec_dir" install -j

  # Might be not detected by default on RHEL
  export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig"
}


build_ffmpeg() {
  local arch="$1"
  local prefix="$2"
  local build_dir="$ffmpeg_source_dir/build/$arch"
  mkdir -p "$build_dir"
  pushd "$build_dir"

  if [ -z  "$prefix" ]
  then prefix="/usr/local/$ffmpeg_name"
  fi

  if [ -n "$arch" ]
  then cc="clang -arch $arch"
  fi

  if [ -n "$arch" ]
  then $ffmpeg_source_dir/configure $ffmpeg_config_options --prefix="$prefix" --enable-cross-compile --arch=$arch --cc="$cc"
  else $ffmpeg_source_dir/configure $ffmpeg_config_options --prefix="$prefix"
  fi
  make install DESTDIR=$build_dir/installed -j4
  popd
}

if [ "$os" == "linux" ]; then
  install_ff_nvcodec_headers

  ffmpeg_config_options+=" --enable-openssl"
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

fi
