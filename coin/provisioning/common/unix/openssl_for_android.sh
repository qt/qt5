#!/usr/bin/env bash
# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script install prebuilt OpenSSL which was built against Android NDK 25.
# OpenSSL build will fail with Android NDK 22, because it's missing platforms and sysroot directories

set -eux
# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

outputPathBase="${HOME}"

sslVersionForLatest="3.5.4"
ndkVersionLatest="r27c"
featureSuffixLatest="_16kb_fixed_symversions"
prebuiltOpensslShaLatest="b9dc30ed77bfd26e526e81d558d6964585b27283"

sslVersionForPreview="3.5.4"
ndkVersionPreview="r29-beta2"
featureSuffixPreview="_16kb_fixed_symversions"
prebuiltOpensslShaPreview="89b6692e983c7e9678dcd9fc03da623fb75593d3"

ndkVersionNightly1=$ndkVersionLatest
sslVersionForNightly1=$sslVersionForLatest
featureSuffixNightly1=""
prebuiltOpensslShaNightly1=$prebuiltOpensslShaLatest

ndkVersionNightly2=$ndkVersionLatest
sslVersionForNightly2=$sslVersionForLatest
featureSuffixNightly2=""
prebuiltOpensslShaNightly2=$prebuiltOpensslShaLatest

: <<'EOB' SOURCE BUILD INSTRUCTIONS
Openssl 3.5.4 prebuilt was made using Android NDK r27c Revision 27.2.12479018
and r29-beta2 Revision 29.0.13599879

By using a helpful (build_ssl.sh) script from:
Android OpenSSL support for Qt
https://github.com/KDAB/android_openssl/commit/b71f1470962019bd89534a2919f5925f93bc5779

Download the same NDK version that the Qt branch supports
https://developer.android.com/ndk/downloads

Modify the script to your liking: set a path to NDK root, set OpenSSL version
(script will download needed OpenSSL packages)
Set ANDROID_API to the lowest version of Android which will be used.
EOB

function BuildOutputPath() {
    local ndkVersion="$1"
    local suffix="$2"
    local sslVersion="$3"

    echo "${outputPathBase}/prebuilt-openssl-${sslVersion}-for-android-ndk-${ndkVersion}${suffix}"
}

function InstallPrebuiltOpenssl() {
    local ndkVersion="$1"
    local suffix="$2"
    local sha="$3"
    local sslVersion="$4"
    local output_dir="$5"

    local prebuiltUrl="http://ci-files01-hki.ci.qt.io/input/openssl/prebuilt-openssl-${sslVersion}-for-android-ndk-${ndkVersion}${suffix}.zip"
    local targetFile="/tmp/prebuilt-openssl-${sslVersion}-for-android-ndk-${ndkVersion}${suffix}.zip"

    DownloadURL "$prebuiltUrl" "$prebuiltUrl" "$sha" "$targetFile"

    local tmp_extract
    tmp_extract="$(mktemp -d "${TMPDIR:-/tmp}/openssl-extract.XXXXXX")"
    unzip -q -o "$targetFile" -d "$tmp_extract"
    rm -f "$targetFile"

    # We assume there is only one top-level directory in the openssl zip
    local temp_openssl_root
    temp_openssl_root="$(find "$tmp_extract" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
    if [[ -z "$temp_openssl_root" ]]; then
        echo "ERROR: Expected a single top-level directory in the archive, but none was found." >&2
        exit 1
    fi

    mv "$temp_openssl_root" "$output_dir"
    rm -rf "$tmp_extract"

    # There have been cases where necessary symlinks are lost when unarchiving.
    # Force-create them now.
    local abi_list="arm64-v8a armeabi-v7a x86 x86_64"
    for abi in $abi_list; do
        ln -fs "${output_dir}/include" "${output_dir}/${abi}/include"
        ln -fs "${output_dir}/${abi}/libcrypto_3.so" "${output_dir}/${abi}/libcrypto.so"
        ln -fs "${output_dir}/${abi}/libssl_3.so" "${output_dir}/${abi}/libssl.so"
    done
}

if [ "$ndkVersionNightly1" != "$ndkVersionLatest" ]; then
    outputDirNightly1=$(BuildOutputPath \
        "$ndkVersionNightly1" \
        "$featureSuffixNightly1" \
        "$sslVersionForNightly1")

    InstallPrebuiltOpenssl \
        "$ndkVersionNightly1" \
        "$featureSuffixNightly1" \
        "$prebuiltOpensslShaNightly1" \
        "$sslVersionForNightly1" \
        "$outputDirNightly1"
    SetEnvVar "OPENSSL_ANDROID_HOME_NIGHTLY1" "$outputDirNightly1"
    echo "OpenSSL for Android ${ndkVersionNightly1} = ${sslVersionForNightly1}" >> ~/versions.txt
fi

if [ "$ndkVersionNightly2" != "$ndkVersionLatest" ]; then
    outputDirNightly2=$(BuildOutputPath \
        "$ndkVersionNightly2" \
        "$featureSuffixNightly2" \
        "$sslVersionForNightly2")

    InstallPrebuiltOpenssl \
        "$ndkVersionNightly2" \
        "$featureSuffixNightly2" \
        "$prebuiltOpensslShaNightly2" \
        "$sslVersionForNightly2" \
        "$outputDirNightly2"
    SetEnvVar "OPENSSL_ANDROID_HOME_NIGHTLY1" "$outputDirNightly2"
    echo "OpenSSL for Android ${ndkVersionNightly2} = ${sslVersionForNightly2}" >> ~/versions.txt
fi

if [ "$ndkVersionPreview" != "$ndkVersionLatest" ]; then
    outputDirPreview="$(BuildOutputPath \
        "$ndkVersionPreview" \
        "$featureSuffixPreview" \
        "$sslVersionForPreview")"

    InstallPrebuiltOpenssl \
        "$ndkVersionPreview" \
        "$featureSuffixPreview" \
        "$prebuiltOpensslShaPreview" \
        "$sslVersionForPreview" \
        "$outputDirPreview"
    SetEnvVar "OPENSSL_ANDROID_HOME_PREVIEW" "$outputDirPreview"
    echo "OpenSSL for Android ${ndkVersionPreview} = ${sslVersionForPreview}" >> ~/versions.txt
fi

outputDirLatest="$(BuildOutputPath \
    "$ndkVersionLatest" \
    "$featureSuffixLatest" \
    "$sslVersionForLatest")"

InstallPrebuiltOpenssl \
    "$ndkVersionLatest" \
    "$featureSuffixLatest" \
    "$prebuiltOpensslShaLatest" \
    "$sslVersionForLatest" \
    "$outputDirLatest"
SetEnvVar "OPENSSL_ANDROID_HOME_LATEST" "$outputDirLatest"
echo "OpenSSL for Android ${ndkVersionLatest} = ${sslVersionForLatest}" >> ~/versions.txt
