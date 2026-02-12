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

sslVersionForLatest="3.0.7"
ndkVersionLatest="r27c"
featureSuffixLatest="_16kb"
prebuiltOpensslShaLatest="2cc15dd990460c2c7157ab257a47071fbd9e0ac8"

sslVersionForPreview="3.0.7"
ndkVersionPreview="r29-beta2"
featureSuffixPreview="_16kb"
prebuiltOpensslShaPreview="76c9788216440111be97ea1a63c4d8cd807baacd"

ndkVersionNightly1=$ndkVersionLatest
sslVersionForNightly1=$sslVersionForLatest
featureSuffixNightly1=""
prebuiltOpensslShaNightly1=$prebuiltOpensslShaLatest

ndkVersionNightly2=$ndkVersionLatest
sslVersionForNightly2=$sslVersionForLatest
featureSuffixNightly2=""
prebuiltOpensslShaNightly2=$prebuiltOpensslShaLatest

: <<'EOB' SOURCE BUILD INSTRUCTIONS - Openssl prebuilt was made using Android NDK r29-beta2
# Source built requires GCC and Perl to be in PATH. Rhel "requires yum install perl-IPC-Cmd"
exports_file="/tmp/export.sh"
# source previously made environmental variables.
if uname -a |grep -q "Ubuntu"; then
    # shellcheck disable=SC1090
    grep -e "^export" "$HOME/.profile" > $exports_file && source $exports_file
    rm -rf "$exports_file"
else
    # shellcheck disable=SC1090
    grep -e "^export" "$HOME/.bashrc" > $exports_file && source $exports_file
    rm -rf "$exports_file"
fi

officialUrl="https://www.openssl.org/source/openssl-$sslVersionForLatest.tar.gz"
cachedUrl="http://ci-files01-hki.ci.qt.io/input/openssl/openssl-$sslVersionForLatest.tar.gz"
targetFile="/tmp/openssl-$sslVersionForLatest.tar.gz"
sha="f20736d6aae36bcbfa9aba0d358c71601833bf27"
opensslHome="${HOME}/openssl/android/openssl-${sslVersionForLatest}"
DownloadURL "$cachedUrl" "$officialUrl" "$sha" "$targetFile"
mkdir -p "${HOME}/openssl/android/"
tar -xzf "$targetFile" -C "${HOME}/openssl/android/"
if uname -a |grep -q "Darwin"; then
    TOOLCHAIN=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/darwin-x86_64/bin
else
    TOOLCHAIN=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin
fi
cd "$opensslHome"
PATH=$TOOLCHAIN:$PATH CC=clang ./Configure android-arm
PATH=$TOOLCHAIN:$PATH CC=clang make build_generated
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
