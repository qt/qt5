#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

ffmpeg_version_default() {
    echo "n7.1.2"
}

download_ffmpeg() {
    local version="${1:-$(ffmpeg_version_default)}"
    local sha1="${2:-1e4e937facdbde15943dd093121836bf69f27c7c}"

    local ffmpeg_name="FFmpeg-$version"
    local target_dir="$HOME"
    local ffmpeg_source_dir="$target_dir/$ffmpeg_name"

    if [ ! -d "$ffmpeg_source_dir" ]; then
        local url_public="https://github.com/FFmpeg/FFmpeg/archive/refs/tags/$version.tar.gz"
        local url_cached="http://ci-files01-hki.ci.qt.io/input/ffmpeg/$version.tar.gz"
        local app_prefix=""

        source "${BASH_SOURCE%/*}/../unix/InstallFromCompressedFileFromURL.sh"
        InstallFromCompressedFileFromURL "$url_cached" "$url_public" "$sha1" "$target_dir" "$app_prefix" > /dev/null
    fi

    echo "$ffmpeg_source_dir"
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
