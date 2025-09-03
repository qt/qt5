#!/usr/bin/env bash
# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script install prebuilt OpenSSL which was built against Android NDK 25.
# OpenSSL build will fail with Android NDK 22, because it's missing platforms and sysroot directories

set -ex
# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

sslVersionForLatest="3.0.7"
ndkVersionLatest="r27c"
prebuiltOpensslShaLatest="2cc15dd990460c2c7157ab257a47071fbd9e0ac8"

sslVersionForPreview="3.0.7"
ndkVersionPreview="r29-beta2"
prebuiltOpensslShaPreview="76c9788216440111be97ea1a63c4d8cd807baacd"

ndkVersionNightly1=$ndkVersionLatest
sslVersionForNightly1=$sslVersionForLatest
prebuiltOpensslShaNightly1=$prebuiltOpensslShaLatest

ndkVersionNightly2=$ndkVersionLatest
sslVersionForNightly2=$sslVersionForLatest
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

function InstallPrebuiltOpenssl() {

    ndkVersion=$1
    sha=$2
    sslVersion=$3

    opensslHome="${HOME}/prebuilt-openssl-${sslVersion}-for-android-ndk-${ndkVersion}_16kb"
    if [[ ! -d ${opensslHome} ]]; then
        prebuiltUrl="http://ci-files01-hki.ci.qt.io/input/openssl/prebuilt-openssl-${sslVersion}-for-android-ndk-${ndkVersion}_16kb.zip"
        targetFile="/tmp/prebuilt-openssl-${sslVersion}-for-android-ndk-${ndkVersion}_16kb.zip"

        DownloadURL "$prebuiltUrl" "$prebuiltUrl" "$sha" "$targetFile"
        unzip -o "$targetFile" -d "${HOME}"
        sudo rm -f "$targetFile"
    fi
}

if [ "$ndkVersionNightly1" != "$ndkVersionLatest" ]; then
    InstallPrebuiltOpenssl $ndkVersionNightly1 $prebuiltOpensslShaNightly1 $sslVersionForNightly1
    SetEnvVar "OPENSSL_ANDROID_HOME_NIGHTLY1" "$opensslHome"
    echo "OpenSSL for Android $ndkVersionNightly1 = $sslVersionForNightly1" >> ~/versions.txt
fi

if [ "$ndkVersionNightly2" != "$ndkVersionLatest" ]; then
    InstallPrebuiltOpenssl $ndkVersionNightly2 $prebuiltOpensslShaNightly2 $sslVersionForNightly2
    SetEnvVar "OPENSSL_ANDROID_HOME_NIGHTLY2" "$opensslHome"
    echo "OpenSSL for Android $ndkVersionNightly2 = $sslVersionForNightly2" >> ~/versions.txt
fi

if [ "$ndkVersionPreview" != "$ndkVersionLatest" ]; then
    InstallPrebuiltOpenssl $ndkVersionPreview $prebuiltOpensslShaPreview $sslVersionForPreview
    SetEnvVar "OPENSSL_ANDROID_HOME_PREVIEW" "$opensslHome"
    echo "OpenSSL for Android $ndkVersionPreview = $sslVersionForPreview" >> ~/versions.txt
fi

InstallPrebuiltOpenssl $ndkVersionLatest $prebuiltOpensslShaLatest $sslVersionForLatest
SetEnvVar "OPENSSL_ANDROID_HOME_LATEST" "$opensslHome"
echo "OpenSSL for Android $ndkVersionLatest = $sslVersionForLatest" >> ~/versions.txt
