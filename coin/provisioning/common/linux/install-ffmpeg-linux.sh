#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script builds and installs FFmpeg static or shared (default) libs
# It can take an optional output parameter for installation:
#
# install-ffmpeg-linx.sh shared ~/my/install/path

set -ex

source "${BASH_SOURCE%/*}/../unix/ffmpeg-installation-utils.sh"

build_type=$(get_ffmpeg_build_type "$1")

ffmpeg_source_dir=$(download_ffmpeg)
ffmpeg_name=$(basename "$ffmpeg_source_dir")
ffmpeg_config_options=$(get_ffmpeg_config_options "$build_type")
default_prefix="/usr/local/$ffmpeg_name"
prefix="${2:-$default_prefix}"
pkgconfig_path="$PKG_CONFIG_PATH"

install_ff_nvcodec_headers() {
    local nv_codec_version="11.1" # use 11.1 to ensure compatibility with 470 nvidia drivers; might be upated to 12.0
    local nv_codec_url_public="https://github.com/FFmpeg/nv-codec-headers/archive/refs/heads/sdk/$nv_codec_version.zip"
    local nv_codec_url_cached="http://ci-files01-hki.ci.qt.io/input/ffmpeg/nv-codec-headers/nv-codec-headers-sdk-$nv_codec_version.zip"
    local nv_codec_sha1="ceb4966ab01b2e41f02074675a8ac5b331bf603e"
    #nv_codec_sha1="4f30539f8dd31945da4c3da32e66022f9ca59c08" // 12.0
    local target_dir="$HOME"
    local nv_codec_dir="$target_dir/nv-codec-headers-sdk-$nv_codec_version"

    if [ ! -d  "$nv_codec_dir" ]; then
        source "${BASH_SOURCE%/*}/../unix/InstallFromCompressedFileFromURL.sh"
        InstallFromCompressedFileFromURL "$nv_codec_url_cached" "$nv_codec_url_public" "$nv_codec_sha1" "$target_dir" ""
    fi

    sudo make -C "$nv_codec_dir" install -j

    # Might be not detected by default on RHEL
    pkgconfig_path="$pkgconfig_path:/usr/local/lib/pkgconfig"
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

    # on RHEL patchelf is not visible under sudo, so we install to a temporary directory
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

sudo mkdir -p "$prefix"
sudo mv "$output_dir"/* "$prefix"
set_ffmpeg_dir_env_var "FFMPEG_DIR" "$prefix"
