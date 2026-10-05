#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script builds and installs FFmpeg static or shared (default) libs

source "${BASH_SOURCE%/*}/../unix/ffmpeg-installation-utils.sh"

default_prefix="$(ffmpeg_default_install_prefix_base)/linux"

usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [--build-type <type>] [--output <dir>] [--skip-env-var]

Build FFmpeg libraries for Linux.

Options:
  --build-type <type>   One of: shared, static. Defaults to shared.
  --output <dir>        Directory to install FFmpeg into.
                        Defaults to $default_prefix.
  --skip-env-var        Don't set the FFMPEG_DIR environment variable to the
                        installation directory.
  -h, --help            Show this help and exit.

Example:
  $(basename "${BASH_SOURCE[0]}") --build-type static --output ~/my/install/path
EOF
}

build_type="shared"
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
        --build-type|--output)
            if [ $# -lt 2 ]; then
                echo "Error: option '$1' requires a value." >&2
                exit 2
            fi
            case "$1" in
                --build-type) build_type="$2" ;;
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

if [ "$build_type" != "shared" ] && [ "$build_type" != "static" ]; then
    echo "Error: --build-type must be 'shared' or 'static'. Got: '$build_type'" >&2
    exit 2
fi

set -ex

ffmpeg_source_dir=$(download_ffmpeg)
ffmpeg_config_options=$(get_ffmpeg_config_options "$build_type")
pkgconfig_path="$PKG_CONFIG_PATH"

install_ff_nvcodec_headers() {
    local nv_codec_version="12.0.16.1"
    local nv_codec_url_public="https://github.com/FFmpeg/nv-codec-headers/releases/download/n$nv_codec_version/nv-codec-headers-$nv_codec_version.tar.gz"
    local nv_codec_url_cached="http://ci-files01-hki.ci.qt.io/input/ffmpeg/nv-codec-headers/nv-codec-headers-$nv_codec_version.tar.gz"
    local nv_codec_sha1="df7239777af15af5d7e563d2af0deff874c3b770"

    local nv_codec_dir
    nv_codec_dir=$(download_and_extract_source "nv-codec-headers $nv_codec_version" \
        "$nv_codec_url_cached" "$nv_codec_url_public" "$nv_codec_sha1" \
        "$HOME/nv-codec-headers-$nv_codec_version")

    # The headers are only needed while configuring and building FFmpeg,
    # so install them next to the FFmpeg build instead of into /usr/local.
    local nv_codec_prefix="$ffmpeg_source_dir/build/nv-codec-headers"
    make -C "$nv_codec_dir" install PREFIX="$nv_codec_prefix"

    pkgconfig_path="$nv_codec_prefix/lib/pkgconfig:$pkgconfig_path"
}

fix_openssl3_pc_files() {
    # On RHEL 8, openssl3 pc files are libopenssl3.pc, libssl3.pc, libcrypto3.pc,
    # and FFmpeg cannot find them. Instead, it finds FFmpeg 1.x.x if it's installed.
    # The function fixes the files with copying them to a custom directory

    # assign to 'local' to ignore failure exit codes
    local -r openssl3_pcfiledir=$(pkg-config --variable=pcfiledir openssl3)
    if [ -z "$openssl3_pcfiledir" ]; then
        return
    fi

    local pcfiles=("libssl" "libcrypto" "openssl")

    for pcfile in "${pcfiles[@]}"; do
        if [ ! -f "$openssl3_pcfiledir/${pcfile}3.pc" ]; then
            echo "pkgconfig has found openssl3 but the file $openssl3_pcfiledir/${pcfile}3.pc does't exist"
            return
        fi
    done

    local new_pkgconfig_dir="$ffmpeg_source_dir/openssl3_pkgconfig"
    mkdir -p "$new_pkgconfig_dir"

    for pcfile in "${pcfiles[@]}"; do
        sed -E '/^Requires(\.private)?:/s/ (libssl|libcrypto)3/ \1/g;' "$openssl3_pcfiledir/${pcfile}3.pc" > "$new_pkgconfig_dir/${pcfile}.pc"
    done

    pkgconfig_path="$new_pkgconfig_dir:$pkgconfig_path"
}

build_ffmpeg() {
    local build_dir="$ffmpeg_source_dir/build"
    mkdir -p "$build_dir"
    pushd "$build_dir"

    # shellcheck disable=SC2086
    PKG_CONFIG_PATH="$pkgconfig_path" "$ffmpeg_source_dir/configure" $ffmpeg_config_options --prefix="$prefix"
    # shellcheck disable=

    # Install to a staging directory first, so fix_ffmpeg_dependencies.sh can
    # patch the libraries before they are moved into the final prefix.
    make install DESTDIR="$build_dir/installed" -j
    popd
}


ffmpeg_config_options+=" --enable-openssl"
fix_openssl3_pc_files
echo "pkg-config openssl version: $(pkg-config --modversion openssl)"

install_ff_nvcodec_headers

build_ffmpeg

output_dir="$ffmpeg_source_dir/build/installed/$prefix"

if [ "$build_type" == "shared" ]; then
    fix_dependencies="${BASH_SOURCE%/*}/../shared/fix_ffmpeg_dependencies.sh"
    "$fix_dependencies" "$output_dir"
fi

mkdir -p "$prefix"
mv "$output_dir"/* "$prefix"
if [ "$skip_env_var" == "no" ]; then
    set_ffmpeg_dir_env_var "FFMPEG_DIR" "$prefix"
fi
