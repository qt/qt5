#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

download_ffmpeg() (
    local version="${1:-"9.0.1"}"
    local sha1="${2:-89c318905212e6b67e10e42ab10ab8007e0aefda}"

    local ffmpeg_name="FFmpeg-n$version"
    local target_dir="$HOME"
    local ffmpeg_source_dir="$target_dir/$ffmpeg_name"

    if [ ! -d "$ffmpeg_source_dir" ]; then
        local url_public="https://ffmpeg.org/releases/ffmpeg-$version.tar.gz"
        local url_cached="http://ci-files01-hki.ci.qt.io/input/ffmpeg/ffmpeg-$version.tar.gz"
        local app_prefix=""

        local temp_dir
        temp_dir=$(mktemp -d)
        trap 'rm -rf "$temp_dir"' EXIT

        source "${BASH_SOURCE%/*}/../unix/InstallFromCompressedFileFromURL.sh"
        InstallFromCompressedFileFromURL "$url_cached" "$url_public" "$sha1" "$temp_dir" "$app_prefix" > /dev/null

        local extracted_dirs=("$temp_dir"/*/)
        if [ "${#extracted_dirs[@]}" -ne 1 ] || [ ! -d "${extracted_dirs[0]}" ]; then
            >&2 echo "Expected exactly one directory in the FFmpeg archive, got: ${extracted_dirs[*]}"
            exit 1
        fi

        mkdir -p "$target_dir"
        mv "${extracted_dirs[0]%/}" "$ffmpeg_source_dir"
    fi

    echo "$ffmpeg_source_dir"
)

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
