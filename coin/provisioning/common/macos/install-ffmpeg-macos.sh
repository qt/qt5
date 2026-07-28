#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script builds and installs FFmpeg shared libs
# Can take an optional final parameter to control installation directory

set -ex

os="$1"

if [ "$os" != "macos" ] && [ "$os" != "macos-universal" ]; then
    >&2 echo "invalid os paremeter: $os"
    exit 1
fi

source "${BASH_SOURCE%/*}/../unix/ffmpeg-installation-utils.sh"

ffmpeg_source_dir=$(download_ffmpeg)
ffmpeg_name=$(basename "$ffmpeg_source_dir")
ffmpeg_config_options=$(get_ffmpeg_config_options "shared")
default_prefix="/usr/local/$ffmpeg_name"
prefix="${2:-$default_prefix}"

# Disable X11 linkage on macOS. FFmpeg auto-detect
# mechanisms will pull it in as a dependency if found
# on the host. If this happens, it makes the binaries
# not loadable on macOS machines without libx11 installed.
ffmpeg_config_options+=" --disable-libxcb --disable-xlib"

build_ffmpeg() {
    local arch="$1"
    local build_dir="$ffmpeg_source_dir/build/$arch"
    mkdir -p "$build_dir"
    pushd "$build_dir"

    # shellcheck disable=SC2086
    if [ -n "$arch" ]; then
        local cc="clang -arch $arch"
        "$ffmpeg_source_dir/configure" $ffmpeg_config_options --prefix="$prefix" --enable-cross-compile --arch="$arch" --cc="$cc"
    else
        "$ffmpeg_source_dir/configure" $ffmpeg_config_options --prefix="$prefix"
    fi
    # shellcheck disable=

    make install DESTDIR="$build_dir/installed" -j4
    popd
}

# Install required packages through Brew
required_ffmpeg_packages=()
while IFS= read -r line; do required_ffmpeg_packages+=("$line"); done < "${BASH_SOURCE%/*}/../macos/ffmpeg_required_brew_packages.txt"
brew install "${required_ffmpeg_packages[@]}"

export MACOSX_DEPLOYMENT_TARGET=12
fix_relative_dependencies="${BASH_SOURCE%/*}/../macos/fix_relative_dependencies.sh"

if [ "$os" == "macos"  ]; then
    build_ffmpeg

    install_dir="$ffmpeg_source_dir/build/installed"
    "$fix_relative_dependencies" "$install_dir$prefix/lib"
    sudo mkdir -p "$prefix"
    sudo mv "$install_dir$prefix" "$prefix/../"
else
    build_ffmpeg "arm64"
    build_ffmpeg "x86_64"

    arm64_install_dir="$ffmpeg_source_dir/build/arm64/installed"
    x86_64_install_dir="$ffmpeg_source_dir/build/x86_64/installed"

    "$fix_relative_dependencies" "$arm64_install_dir$prefix/lib"
    "$fix_relative_dependencies" "$x86_64_install_dir$prefix/lib"

    sudo rm -rf "$prefix" # lipo fails upon 2nd run
    sudo "${BASH_SOURCE%/*}/../macos/makeuniversal.sh" "$arm64_install_dir" "$x86_64_install_dir"
fi

set_ffmpeg_dir_env_var "FFMPEG_DIR" "$prefix"
