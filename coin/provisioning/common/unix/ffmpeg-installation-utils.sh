#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Downloads a .tar.gz archive containing a single top-level directory and
# extracts that directory to dest_dir, unless dest_dir already exists.
# Prints dest_dir on stdout; all logging goes to stderr.
download_and_extract_source() (
    local name="$1"
    local url_cached="$2"
    local url_public="$3"
    local sha1="$4"
    local dest_dir="$5"

    if [ -d "$dest_dir" ]; then
        >&2 echo "$name source already present at $dest_dir, skipping download"
    else
        local temp_dir
        temp_dir=$(mktemp -d)
        trap 'rm -rf "$temp_dir"' EXIT

        local archive="$temp_dir/archive.tar.gz"
        local extract_dir="$temp_dir/extracted"

        source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
        if ! DownloadURL "$url_cached" "$url_public" "$sha1" "$archive" > /dev/null; then
            >&2 echo "Failed to download $name"
            exit 1
        fi

        mkdir -p "$extract_dir"
        if ! tar -xzf "$archive" --directory "$extract_dir"; then
            >&2 echo "Failed to extract $archive"
            exit 1
        fi

        local extracted_dirs=("$extract_dir"/*/)
        if [ "${#extracted_dirs[@]}" -ne 1 ] || [ ! -d "${extracted_dirs[0]}" ]; then
            >&2 echo "Expected exactly one directory in the $name archive, got: ${extracted_dirs[*]}"
            exit 1
        fi

        mkdir -p "$(dirname "$dest_dir")"
        mv "${extracted_dirs[0]%/}" "$dest_dir"
    fi

    echo "$dest_dir"
)

download_ffmpeg() (
    local version="${1:-"9.0.2"}"
    local sha1="${2:-40c70cddcdc2e32b1b0fad2c85915c9145532452}"
    local url_public="https://ffmpeg.org/releases/ffmpeg-$version.tar.gz"
    local url_cached="http://ci-files01-hki.ci.qt.io/input/ffmpeg/ffmpeg-$version.tar.gz"

    download_and_extract_source "FFmpeg $version" "$url_cached" "$url_public" "$sha1" "$HOME/FFmpeg-n$version"
)

# Must be appended by platform.
# E.g "$(ffmpeg_default_install_prefix_base)/macos"
# or "$(ffmpeg_default_install_prefix_base)/android/arm64"
ffmpeg_default_install_prefix_base() {
    echo "$HOME/ffmpeg-install"
}

get_ffmpeg_config_options() {
    local build_type="$1"
    local result

    result=$(cat "${BASH_SOURCE%/*}/../shared/ffmpeg_config_options.txt")

    if [ "$build_type" != "static" ]; then
        result+=" --enable-shared --disable-static"
    fi

    echo "$result"
}


get_ffmpeg_build_type() {
    local result="${1:-shared}"

    if [ "$result" != "static" ] && [ "$result" != "shared" ]; then
        >&2 echo "Invalid build_type: $result. The shared build type will be used."
        result="shared"
    fi

    echo "$result"
}

set_ffmpeg_dir_env_var() {
    local envvar="$1"
    local dir="$2"

    if [ ! -d "$dir" ]; then
        >&2 echo "the FFmpeg dir $dir doesn't exist"
        exit 1
    fi

    # minimal validity check, more checks can be added
    if [ ! -d "$dir/include" ] || [ ! -d "$dir/lib" ]; then
        >&2 echo "The FFmpeg dir $dir is not valid"
        exit 1
    fi

    source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"
    SetEnvVar "$envvar" "$dir"
}

set_ffmpeg_env_var() {
    local envvar="$1"
    local value="$2"

    source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"
    SetEnvVar "$envvar" "$value"
}
