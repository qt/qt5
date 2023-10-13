#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script install prebuilt OpenSSL which was built against Android NDK 25.
# OpenSSL build will fail with Android NDK 22, because it's missing platforms and sysroot directories

set -ex
# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

version="3.0.7"
ndkVersionLatest="r26b"
ndkVersionDefault=$ndkVersionLatest
prebuiltOpensslNdkShaLatest="ea925d5a5b696916fb3650403a2eb3189c52b5ce"
prebuiltOpensslNdkShaDefault=$prebuiltOpensslNdkShaLatest

: <<'EOB' SOURCE BUILD INSTRUCTIONS - Openssl prebuilt was made using Android NDK 25
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

# ANDROID_NDK_ROOT is required during Configure
export ANDROID_NDK_ROOT=/opt/android/android-ndk-r26b

officialUrl="https://www.openssl.org/source/openssl-$version.tar.gz"
cachedUrl="http://ci-files01-hki.ci.qt.io/input/openssl/openssl-$version.tar.gz"
targetFile="/tmp/openssl-$version.tar.gz"
sha="f20736d6aae36bcbfa9aba0d358c71601833bf27"
opensslHome="${HOME}/openssl/android/openssl-${version}"
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

    opensslHome="${HOME}/prebuilt-openssl-${version}-for-android-ndk-${ndkVersion}"
    if [[ ! -d ${opensslHome} ]]; then
        prebuiltUrl="http://ci-files01-hki.ci.qt.io/input/openssl/prebuilt-openssl-${version}-for-android-ndk-${ndkVersion}.zip"
        targetFile="/tmp/prebuilt-openssl-${version}-for-android-ndk-${ndkVersion}.zip"

        DownloadURL "$prebuiltUrl" "$prebuiltUrl" "$sha" "$targetFile"
        unzip -o "$targetFile" -d "${HOME}"
        sudo rm -f "$targetFile"
    fi
}

InstallPrebuiltOpenssl $ndkVersionDefault $prebuiltOpensslNdkShaDefault
SetEnvVar "OPENSSL_ANDROID_HOME_DEFAULT" "$opensslHome"
InstallPrebuiltOpenssl $ndkVersionLatest $prebuiltOpensslNdkShaLatest
SetEnvVar "OPENSSL_ANDROID_HOME_LATEST" "$opensslHome"

echo "OpenSSL for Android = $version" >> ~/versions.txt
