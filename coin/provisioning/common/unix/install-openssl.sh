#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script install OpenSSL from sources.
# Requires GCC and Perl to be in PATH.
set -ex
os="$1"
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"
version="3.0.7"
officialUrl="https://www.openssl.org/source/openssl-$version.tar.gz"
cachedUrl="http://ci-files01-hki.ci.qt.io/input/openssl/openssl-$version.tar.gz"
targetFile="/tmp/openssl-$version.tar.gz"
sha="f20736d6aae36bcbfa9aba0d358c71601833bf27"
opensslHome="${HOME}/openssl-${version}"
opensslSource="${opensslHome}-src"
DownloadURL "$cachedUrl" "$officialUrl" "$sha" "$targetFile"
mkdir -p "$opensslSource"
tar -xzf "$targetFile" --strip 1 -C "$opensslSource"
cd "$opensslSource"
pwd

if [[ "$os" == "linux" ]]; then
    if [ $(uname -m) = aarch64 ]; then
        arch=$(uname -m)
    else
        arch="x86_64"
    fi
    ./Configure --prefix="$opensslHome" shared enable-ec_nistp_64_gcc_128 "linux-$arch" "-Wa,--noexecstack"
    make && make install_sw install_ssldirs
    SetEnvVar "OPENSSL_HOME" "$opensslHome"
    SetEnvVar "PATH" "\"$opensslHome/bin:\$PATH\""
    if uname -a |grep -q "Debian"; then
        SetEnvVar "LD_LIBRARY_PATH" "\"$opensslHome/lib:$LD_LIBRARY_PATH\""
    else
        SetEnvVar "LD_LIBRARY_PATH" "\"$opensslHome/lib64:$LD_LIBRARY_PATH\""
    fi
elif [ "$os" == "macos" ] || [ "$os" == "macos-universal" ]; then
    # Below target location has been hard coded into Coin.
    # QTQAINFRA-1195
    echo "prefix=$prefix"
    if [[ -z "$prefix" ]]; then
        prefix="/usr/local"
    fi
    openssl_install_dir="$prefix/openssl-$version"
    opensslTargetLocation="$prefix/opt/openssl"

    commonFlags=(no-tests shared no-ssl3-method enable-ec_nistp_64_gcc_128 "-Wa,--noexecstack")

    export MACOSX_DEPLOYMENT_TARGET=12

    opensslBuild="${opensslHome}-build"
    opensslDestdir="${opensslHome}-destdir"
    mkdir -p "$opensslBuild"

    if [ "$os" == "macos-universal" ]; then
        archs="x86_64 arm64"
    else
        archs="$(uname -m)"
    fi

    for arch in $archs; do
        cd "$opensslBuild"
        echo "Configuring OpenSSL for $arch"
        mkdir -p "$arch" && cd "$arch"
        "$opensslSource/Configure" --prefix="$openssl_install_dir" "${commonFlags[@]}" "darwin64-$arch-cc"

        echo "Building OpenSSL for $arch in $PWD"
        make >> /tmp/openssl_make.log 2>&1

        echo "Installing OpenSSL for $arch"
        if [ "$os" == "macos-universal" ]; then
            destdir="$opensslDestdir/$arch"
        else
            destdir=""
        fi
        # shellcheck disable=SC2024
        sudo make install_sw install_ssldirs DESTDIR="$destdir" >> /tmp/openssl_make_install.log 2>&1
    done

    if [ "$os" == "macos-universal" ]; then
        echo "Making universal OpenSSL package"
        # shellcheck disable=SC2024
        sudo rm -Rf "$openssl_install_dir"
        sudo "${SCRIPT_DIR}/../macos/makeuniversal.sh" "$opensslDestdir/x86_64" "$opensslDestdir/arm64"
    fi

    path=$(echo "$opensslTargetLocation" | sed -E 's/(.*)\/.*$/\1/')
    sudo mkdir -p "$path"
    sudo ln -s "$openssl_install_dir" "$opensslTargetLocation"

    SetEnvVar "PATH" "\"$opensslTargetLocation/bin:\$PATH\""
    SetEnvVar "MANPATH" "\"$opensslTargetLocation/share/man:\$MANPATH\""

    SetEnvVar "OPENSSL_DIR" "\"$openssl_install_dir\""
    SetEnvVar "OPENSSL_INCLUDE" "\"$openssl_install_dir/include\""
    SetEnvVar "OPENSSL_LIB" "\"$openssl_install_dir/lib\""

    security find-certificate -a -p /Library/Keychains/System.keychain | sudo tee -a "$opensslTargetLocation/ssl/cert.pem" > /dev/null
    security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain | sudo tee -a "$opensslTargetLocation/ssl/cert.pem" > /dev/null
fi


echo "OpenSSL = $version" >> ~/versions.txt
