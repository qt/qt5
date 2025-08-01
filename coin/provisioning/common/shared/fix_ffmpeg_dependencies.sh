#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -euox pipefail

lib_dir="$1/lib"
additional_suffix="${2:-}"
set_rpath="${3:-yes}"

# readelf and patchelf are prerequisite tools for this script. Check
# that they are available.
if [ "$(uname -s)" = "Darwin" ]; then
    # Under Homebrew, binutils package is not symlinked into PATH.
    # This lets us use readelf provided by Homebrew.
    readelf_homebrew_path="$(brew --prefix binutils)/bin/readelf"
    if [[ ! -x "$readelf_homebrew_path" ]]; then
        echo "Found no valid readelf executable. It is possible it was not correctly installed through Homebrew."
        exit 1
    fi
    readelf() { "$readelf_homebrew_path" "$@"; }
fi

if ! command -v readelf; then
    echo "Found no valid readelf command. It is possible it was not correctly installed."
    exit 1
fi

if ! command -v patchelf; then
    echo "Found no valid patchelf command. It is possible it was not correctly installed."
    exit 1
fi

# Get patchelf version
patchelf_version=$(patchelf --version 2>/dev/null | awk '{print $2}')
if [[ "$patchelf_version" == "0.18.0" ]]; then
    echo "WARNING: patchelf version 0.18.0 is known to have issues with Android." >&2
fi

ffmpeg_libs=("avcodec" "avdevice" "avfilter" "avformat" "avutil" "swresample" "swscale")
stub_prefix="Qt6FFmpegStub-"

for lib_name in "${ffmpeg_libs[@]}"; do
    lib_path="$lib_dir/lib$lib_name.so"
    pkg_config_file_path="$lib_dir/pkgconfig/lib$lib_name.pc"
    stubs_required_versions=""

    if [ ! -f "$lib_path" ]; then
        echo "FFmpeg lib $lib_path hasn't been found"
        exit 1
    fi

    if [ ! -f "$pkg_config_file_path" ]; then
        echo "FFmpeg pc file $pkg_config_file_path hasn't been found"
        exit 1
    fi

    read_needed_deps() {
        readelf -d "$lib_path" | grep '(NEEDED)'
    }

    while read -r line; do
        if [[ $line =~ .*\[(lib((ssl|crypto|va|va-x11|va-drm)(_3)?\.so(\.[0-9]+)*))\].* ]]; then
            stub_name="lib$stub_prefix${BASH_REMATCH[2]}"
            android_ssl_suffix=${BASH_REMATCH[4]}
            soversion=${BASH_REMATCH[5]}

            if [ -n "$android_ssl_suffix" ] && [ -n "$soversion" ]; then
                >&2 echo "both, android_ssl_suffix $android_ssl_suffix and soversion $soversion are found"
                continue
            fi

            if [[ "$android_ssl_suffix" == "_3" ]]; then
                stub_name="${stub_name/_3/}"  # Remove "_3" from stub_name
                stubs_required_versions+=" ${stub_name/.so/ = 3},"
            elif [[ -n "$soversion" ]]; then
                stubs_required_versions+=" ${stub_name/.so./ = },"
            fi

            if [[ -n "$additional_suffix" ]]; then
                stub_name="${stub_name%%.*}${additional_suffix}.${stub_name#*.}" # Add additional_suffix
            fi

            patchelf --replace-needed "${BASH_REMATCH[1]}" "${stub_name}" "$lib_path"
        fi
    done <<< "$(read_needed_deps)"

    sed_cmd="/^Libs.private:/s/ -l(va|va-x11|va-drm|ssl|crypto)/ -l$stub_prefix\\1/g;"
    if [[ -n "$stubs_required_versions" ]]; then
        stubs_required_versions="${stubs_required_versions%?}" # remove the last comma
        sed_cmd+="s/(^Requires.private:[^,]*(,)?.*$)/\\1\\2$stubs_required_versions/g;"
    fi

    # sed -i doesn't work without parameter on macOS 13
    sed -i.bak -E "$sed_cmd" "$pkg_config_file_path" && rm -f "${pkg_config_file_path}.bak"
    if [[ "$set_rpath" == "yes" ]]; then
        # shellcheck disable=SC2016
        patchelf --set-rpath '$ORIGIN' "$lib_path"
    fi
done
