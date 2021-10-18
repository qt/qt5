#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2021 The Qt Company Ltd.
## Contact: http://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL21$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see http://www.qt.io/terms-conditions. For further
## information use the contact form at http://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 2.1 or version 3 as published by the Free
## Software Foundation and appearing in the file LICENSE.LGPLv21 and
## LICENSE.LGPLv3 included in the packaging of this file. Please review the
## following information to ensure the GNU Lesser General Public License
## requirements will be met: https://www.gnu.org/licenses/lgpl.html and
## http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
##
## As a special exception, The Qt Company gives you certain additional
## rights. These rights are described in The Qt Company LGPL Exception
## version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
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

version="1.1.1k"
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
sha="bad9dc4ae6dcc1855085463099b5dacb0ec6130b"
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

if uname -a |grep -q "Darwin"; then
    prebuiltUrl="http://ci-files01-hki.intra.qt.io/input/openssl/prebuilt-openssl-1_1_1_k_for-android-ndk-21_darwin.tar.gz"
    sha="6e3e48441ff58596f25bc27fdc05ae43e5a7581d"
else
    prebuiltUrl="http://ci-files01-hki.intra.qt.io/input/openssl/prebuilt-openssl-1_1_1_k_for-android-ndk-21.tar.gz"
    sha="8c4db1eb8460d749c998a0e033b3939123cbc5ac"
fi
targetFile="/tmp/prebuilt-openssl-$version.tar.gz"
DownloadURL "$prebuiltUrl" "$prebuiltUrl" "$sha" "$targetFile"
tar -xzf "$targetFile" -C "${HOME}"

opensslHome="${HOME}/openssl/android/openssl-${version}"
SetEnvVar "OPENSSL_ANDROID_HOME" "$opensslHome"

echo "OpenSSL for Android = $version" >> ~/versions.txt
