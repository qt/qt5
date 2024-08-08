#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script will build and install FFmpeg static libs
set -ex

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
ffmpeg_source_dir="$target_dir/$ffmpeg_name"
prefix="/usr/local/ios/ffmpeg"

if [ ! -d "$ffmpeg_source_dir" ];
then
   InstallFromCompressedFileFromURL "$url_cached" "$url_public" "$sha1" "$target_dir"
fi

ffmpeg_config_options=$(cat "${BASH_SOURCE%/*}/../shared/ffmpeg_config_options.txt")

build_ffmpeg_ios() {
  local target_arch=$1

  if [ "$target_arch" == "x86_64" ]; then
     target_sdk="iphonesimulator"
     target_arch="x86_64"
     minos="-mios-simulator-version-min=13.0"
  else
     target_sdk="iphoneos"
     target_arch="arm64"
     minos="-miphoneos-version-min=13.0"
  fi

  local build_dir="$ffmpeg_source_dir/build_ios/$target_arch"
  sudo mkdir -p "$build_dir"
  pushd "$build_dir"

  # shellcheck disable=SC2086
  sudo "$ffmpeg_source_dir/configure" $ffmpeg_config_options \
    --sysroot="$(xcrun --sdk "$target_sdk" --show-sdk-path)" \
  --enable-cross-compile \
  --enable-optimizations \
  --prefix=$prefix \
  --arch=$target_arch \
  --cc="xcrun --sdk ${target_sdk} clang -arch $target_arch" \
  --cxx="xcrun --sdk ${target_sdk} clang++ -arch $target_arch" \
  --ar="$(xcrun --sdk ${target_sdk} --find ar)" \
  --ranlib="$(xcrun --sdk ${target_sdk} --find ranlib)" \
  --strip="$(xcrun --sdk ${target_sdk} --find strip)" \
  --nm="$(xcrun --sdk ${target_sdk} --find nm)" \
  --target-os=darwin \
  --extra-cflags="$minos" \
  --extra-cxxflags="$minos" \
  --enable-cross-compile \
  --enable-shared \
  --disable-static \
  --install-name-dir='@rpath/Frameworks' \
  --enable-swscale \
  --enable-pthreads \
  --disable-audiotoolbox

  sudo make install DESTDIR="$build_dir/installed" -j
  popd
}

install_ffmpeg() {
    for dir in "$@"; do
        echo "Processing files in $dir ..."
        pushd "$dir" >/dev/null
        find . -type l -name '*.*.dylib' | while read -r f; do
            dst="${f:1}"
            dstdir="$(dirname "$dst")"
            sudo mkdir -p "$dstdir"

            if [[ ! -f "$dst" ]]; then
                echo "<Copying $dir/$f to $dst"
                sudo cp -c "$f" "$dst"
                symlinkname="$(tmp=${f/*\/}; echo ${tmp/\.*}).dylib"
                sudo ln -s "$(basename -- "$f")" $dstdir/"$symlinkname"
            elif lipo -info "$f" >/dev/null 2>&1; then
                echo "Lipoing $dir/$f into $dst"
                sudo lipo -create -output "$dst" "$dst" "$f"
            elif ! diff "$f" "$dst"; then
                echo "Error: File $f in $dir doesn't match destination $dst"
                exit 1
            fi
        done
        echo "LS"
        popd >/dev/null
    done
    sudo cp -r $1$prefix/include $prefix
    echo "LS done."
}

build_ffmpeg_ios "x86_64"
build_ffmpeg_ios "arm64"

install_ffmpeg "$ffmpeg_source_dir/build_ios/x86_64/installed" "$ffmpeg_source_dir/build_ios/arm64/installed"
SetEnvVar "FFMPEG_DIR_IOS" $prefix
