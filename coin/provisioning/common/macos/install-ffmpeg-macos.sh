#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script builds and installs FFmpeg shared libs

source "${BASH_SOURCE%/*}/../unix/ffmpeg-installation-utils.sh"

default_prefix="$(ffmpeg_default_install_prefix_base)/macos"

usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") --os <os> [--output <dir>] [--skip-env-var]

Build FFmpeg shared libraries for macOS.

Options:
  --os <os>             Target. One of: macos, macos-universal.
                        macos builds for the host architecture only,
                        macos-universal builds arm64 and x86_64 and lipos them together.
  --output <dir>        Directory to install FFmpeg into.
                        Defaults to $default_prefix.
  --skip-env-var        Don't set the FFMPEG_DIR environment variable to the
                        installation directory.
  -h, --help            Show this help and exit.

Example:
  $(basename "${BASH_SOURCE[0]}") --os macos-universal --output ~/my/ffmpeg/macos
EOF
}

os=""
prefix="$default_prefix"
skip_env_var="no"

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --skip-env-var)
            skip_env_var="yes"
            ;;
        --os|--output)
            if [ $# -lt 2 ]; then
                echo "Error: option '$1' requires a value." >&2
                exit 2
            fi
            case "$1" in
                --os) os="$2" ;;
                --output) prefix="$2" ;;
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

set -euxo pipefail

if [ "$os" != "macos" ] && [ "$os" != "macos-universal" ]; then
    echo "Error: --os must be 'macos' or 'macos-universal'. Got: '$os'" >&2
    exit 1
fi

ffmpeg_source_dir=$(download_ffmpeg)
ffmpeg_config_options=$(get_ffmpeg_config_options "shared")

# Disable X11 linkage on macOS. FFmpeg auto-detect
# mechanisms will pull it in as a dependency if found
# on the host. If this happens, it makes the binaries
# not loadable on macOS machines without libx11 installed.
ffmpeg_config_options+=" --disable-libxcb --disable-xlib"

build_ffmpeg() {
    local arch="${1:-}"
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
    "$fix_relative_dependencies" "$install_dir/$prefix/lib"
    mkdir -p "$prefix"
    mv "$install_dir/$prefix" "$prefix/../"
else
    build_ffmpeg "arm64"
    build_ffmpeg "x86_64"

    arm64_install_dir="$ffmpeg_source_dir/build/arm64/installed"
    x86_64_install_dir="$ffmpeg_source_dir/build/x86_64/installed"

    "$fix_relative_dependencies" "$arm64_install_dir/$prefix/lib"
    "$fix_relative_dependencies" "$x86_64_install_dir/$prefix/lib"

    rm -rf "$prefix" # lipo fails upon 2nd run
    "${BASH_SOURCE%/*}/../macos/makeuniversal.sh" "$arm64_install_dir" "$x86_64_install_dir"
fi

if [ "$skip_env_var" == "no" ]; then
    set_ffmpeg_dir_env_var "FFMPEG_DIR" "$prefix"
fi
