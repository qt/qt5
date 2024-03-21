#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -x

lib_dir="$1/lib"

ffmpeg_libs=("avcodec" "avdevice" "avfilter" "avformat" "avutil" "swresample" "swscale")

for lib_name in "${ffmpeg_libs[@]}"; do
    lib_path="$lib_dir/lib$lib_name.so"
    pkg_config_file_path="$lib_dir/pkgconfig/lib$lib_name.pc"

    if [ ! -f "$lib_path" ]; then
        echo "FFmpeg lib $lib_path hasn't been found"
        exit 1
    fi

    if [ ! -f "$pkg_config_file_path" ]; then
        echo "FFmpeg pc file $pkg_config_file_path hasn't been found"
        exit 1
    fi

    while read -r line; do
        if [[ $line =~ .*\[(lib((ssl|crypto|va|va-x11|va-drm)\.so(\.[0-9]+)*))\].* ]]; then
            patchelf --replace-needed "${BASH_REMATCH[1]}" "libQt6FFmpegStub-${BASH_REMATCH[2]}" $lib_path
        fi
    done <<< "$(readelf -d $lib_path | grep '(NEEDED)' )"

    sed -i -E "/^Libs.private:/s/ -l(va|va-x11|va-drm|ssl|crypto)/ -lQt6FFmpegStub-\\1/g;" $pkg_config_file_path
    patchelf --set-rpath '$ORIGIN' $lib_path
done
