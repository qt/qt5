#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script will build and install multiple variants of FFmpeg,
# one for each NDK version. It also sets the relevant environment
# variables for FFmpeg.
#
# Note! The environment variable names used here must match those that are
# used when building Qt in CI.

usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") --abi <abi> --page-size <size>

Build FFmpeg libraries for Android, once for each NDK available in the environment.

Options:
  --abi <abi>           Target Android ABI. One of: arm64, arm32, x86, x86_64.
  --page-size <size>    One of: 4kb, 16kb.
  -h, --help            Show this help and exit.

Example:
  $(basename "${BASH_SOURCE[0]}") --abi arm64 --page-size 16kb
EOF
}

abi=""
page_size=""

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --abi|--page-size)
            if [ $# -lt 2 ]; then
                echo "Error: option '$1' requires a value." >&2
                exit 2
            fi
            case "$1" in
                --abi) abi="$2" ;;
                --page-size) page_size="$2" ;;
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

source "${BASH_SOURCE%/*}/ffmpeg-installation-utils.sh"

is_populated_dir() {
    local value="$1"
    [ -n "$value" ] || return 1
    [ -d "$value" ] || return 1
    find "$value" -mindepth 1 -maxdepth 1 -print -quit >/dev/null 2>&1 || return 1
}

assert_envvar_is_populated_dir() {
    local envvar="$1"
    local value="${!envvar}"
    if [ -z "$value" ] || ! is_populated_dir "$value" ; then
        echo "Environment variable '$envvar' is unset, or the directory is not populated."
        exit 1
    fi
}

set -eux

ENVVAR_NAME_BASE="FFMPEG_DIR_ANDROID"
OUTPUT_PATH_BASE="/usr/local/android"

# Set up environment name and output directory based on ABI parameter.
# The envvar name will be suffixed with the specific NDK version we
# are building with.
envvar_name=""
output_path=""
case "$abi" in
    x86)
        output_path="${OUTPUT_PATH_BASE}/ffmpeg-x86"
        envvar_name="${ENVVAR_NAME_BASE}_X86"
        ;;
    x86_64)
        output_path="${OUTPUT_PATH_BASE}/ffmpeg-x86_64"
        envvar_name="${ENVVAR_NAME_BASE}_X86_64"
        ;;
    arm32)
        output_path="${OUTPUT_PATH_BASE}/ffmpeg-arm32"
        envvar_name="${ENVVAR_NAME_BASE}_ARM32"
        ;;
    arm64)
        output_path="${OUTPUT_PATH_BASE}/ffmpeg-arm64"
        envvar_name="${ENVVAR_NAME_BASE}_ARM64"
        ;;
    *)
        echo "Error: --abi must be one of: arm64, arm32, x86, x86_64. Got: '$abi'" >&2
        exit 1
        ;;
esac

if [ "$page_size" != "16kb" ] && [ "$page_size" != "4kb" ]; then
    echo "Error: --page-size must be '4kb' or '16kb'. Got: '$page_size'" >&2
    exit 1
fi

install_ffmpeg() {
    local ndk_root="$1"
    local openssl_root="$2"
    local output_dir="$3"
    "${BASH_SOURCE%/*}/install-ffmpeg-android.sh" \
        --abi "$abi" \
        --ndk "$ndk_root" \
        --openssl "$openssl_root" \
        --page-size "$page_size" \
        --output "$output_dir"
}

assert_envvar_is_populated_dir "ANDROID_NDK_ROOT_LATEST"
assert_envvar_is_populated_dir "OPENSSL_ANDROID_HOME_LATEST"
output_dir_latest="$output_path/ndk-latest"
install_ffmpeg "$ANDROID_NDK_ROOT_LATEST" "$OPENSSL_ANDROID_HOME_LATEST" "$output_dir_latest"
set_ffmpeg_dir_env_var "${envvar_name}_NDK_LATEST" "$output_dir_latest"

if [ -n "${ANDROID_NDK_ROOT_PREVIEW-}" ]; then
    assert_envvar_is_populated_dir "OPENSSL_ANDROID_HOME_PREVIEW"
    output_dir_preview="$output_path/ndk-preview"
    install_ffmpeg "$ANDROID_NDK_ROOT_PREVIEW" "$OPENSSL_ANDROID_HOME_PREVIEW" "$output_dir_preview"
    set_ffmpeg_dir_env_var "${envvar_name}_NDK_PREVIEW" "$output_dir_preview"
fi

if [ -n "${ANDROID_NDK_ROOT_NIGHTLY1-}" ]; then
    assert_envvar_is_populated_dir "OPENSSL_ANDROID_HOME_NIGHTLY1"
    output_dir_nightly1="$output_path/ndk-nightly1"
    install_ffmpeg "$ANDROID_NDK_ROOT_NIGHTLY1" "$OPENSSL_ANDROID_HOME_NIGHTLY1" "$output_dir_nightly1"
    set_ffmpeg_dir_env_var "${envvar_name}_NDK_NIGHTLY1" "$output_dir_nightly1"
fi

if [ -n "${ANDROID_NDK_ROOT_NIGHTLY2-}" ]; then
    assert_envvar_is_populated_dir "OPENSSL_ANDROID_HOME_NIGHTLY2"
    output_dir_nightly2="$output_path/ndk-nightly2"
    install_ffmpeg "$ANDROID_NDK_ROOT_NIGHTLY2" "$OPENSSL_ANDROID_HOME_NIGHTLY2" "$output_dir_nightly2"
    set_ffmpeg_dir_env_var "${envvar_name}_NDK_NIGHTLY2" "$output_dir_nightly2"
fi
