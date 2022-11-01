#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2022 The Qt Company Ltd.
## Contact: https://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see https://www.qt.io/terms-conditions. For further
## information use the contact form at https://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 3 as published by the Free Software
## Foundation and appearing in the file LICENSE.LGPL3 included in the
## packaging of this file. Please review the following information to
## ensure the GNU Lesser General Public License version 3 requirements
## will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 2.0 or (at your option) the GNU General
## Public license version 3 or any later version approved by the KDE Free
## Qt Foundation. The licenses are as published by the Free Software
## Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
## included in the packaging of this file. Please review the following
## information to ensure the GNU General Public License requirements will
## be met: https://www.gnu.org/licenses/gpl-2.0.html and
## https://www.gnu.org/licenses/gpl-3.0.html.
##
## $QT_END_LICENSE$
##
#############################################################################

# This script install prebuilt OpenSSL which was built against Android NDK 21.
# OpenSSL build will fail with Android NDK 22, because it's missing platforms and sysroot directories

set -ex
# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

version="1.1.1m"
ndkVersionLatest="r23b"
ndkVersionDefault=$ndkVersionLatest
prebuiltOpensslNdkShaDarwinLatest="2624b0c2772e360bbbae7a7f2dc342e4b97f1a2e"
prebuiltOpensslNdkShaLinuxLatest="f58dcb32b2d3e5edc7e5141ae139a50547805f60"
prebuiltOpensslNdkShaDarwinDefault=$prebuiltOpensslNdkShaDarwinLatest
prebuiltOpensslNdkShaLinuxDefault=$prebuiltOpensslNdkShaLinuxLatest

: ' SOURCE BUILD INSTRUCTIONS - Openssl prebuilt was made using Android NDK 21
# Source built requires GCC and Perl to be in PATH.
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

officialUrl="https://www.openssl.org/source/openssl-$version.tar.gz"
cachedUrl="http://ci-files01-hki.intra.qt.io/input/openssl/openssl-$version.tar.gz"
targetFile="/tmp/openssl-$version.tar.gz"
sha="39d424c4411e45f1570073d7a71b1830b96007ca"
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
'

function InstallPrebuiltOpenssl() {

    ndkVersion=$1
    nkdSha=$2
    os=$3

    if [[ ! -d ${HOME}/openssl_android_ndk_${ndkVersion}/android/openssl-${version} ]]; then
        prebuiltUrl="http://ci-files01-hki.intra.qt.io/input/openssl/prebuilt-openssl-${version}-for-android-ndk-${ndkVersion}-${os}.tar.gz"
        targetFile="/tmp/prebuilt-openssl-${version}-for-android-ndk-${ndkVersion}-${os}.tar.gz"

        DownloadURL "$prebuiltUrl" "$prebuiltUrl" "$nkdSha" "$targetFile"
        tar -xzf "$targetFile" -C "${HOME}"
        mv "${HOME}/openssl" "${HOME}/openssl_android_ndk_${ndkVersion}"
        opensslHome="${HOME}/openssl_android_ndk_${ndkVersion}/android/openssl-${version}"
        sudo rm -f $targetFile
    fi
}

if uname -a |grep -q "Darwin"; then
    InstallPrebuiltOpenssl $ndkVersionDefault $prebuiltOpensslNdkShaDarwinDefault "darwin"
    SetEnvVar "OPENSSL_ANDROID_HOME_DEFAULT" "$opensslHome"
    InstallPrebuiltOpenssl $ndkVersionLatest $prebuiltOpensslNdkShaDarwinLatest "darwin"
    SetEnvVar "OPENSSL_ANDROID_HOME_LATEST" "$opensslHome"
else
    InstallPrebuiltOpenssl $ndkVersionDefault $prebuiltOpensslNdkShaLinuxDefault "linux"
    SetEnvVar "OPENSSL_ANDROID_HOME_DEFAULT" "$opensslHome"
    InstallPrebuiltOpenssl $ndkVersionLatest $prebuiltOpensslNdkShaLinuxLatest "linux"
    SetEnvVar "OPENSSL_ANDROID_HOME_LATEST" "$opensslHome"
fi

echo "OpenSSL for Android = $version" >> ~/versions.txt
