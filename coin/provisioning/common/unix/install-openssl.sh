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

# This script install OpenSSL from sources.
# Requires GCC and Perl to be in PATH.
set -ex
os="$1"
# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

version="1.1.1k"
officialUrl="https://www.openssl.org/source/openssl-$version.tar.gz"
cachedUrl="http://ci-files01-hki.intra.qt.io/input/openssl/openssl-$version.tar.gz"
targetFile="/tmp/openssl-$version.tar.gz"
sha="bad9dc4ae6dcc1855085463099b5dacb0ec6130b"
opensslHome="${HOME}/openssl-${version}"
opensslSource="${opensslHome}-src"
DownloadURL "$cachedUrl" "$officialUrl" "$sha" "$targetFile"
tar -xzf "$targetFile" -C "$HOME"
mv "$opensslHome" "$opensslSource"
cd "$opensslSource"
pwd

if [[ "$os" == "linux" ]]; then
    ./Configure --prefix="$opensslHome" shared no-ssl3-method enable-ec_nistp_64_gcc_128 linux-x86_64 "-Wa,--noexecstack"
    make && make install_sw install_ssldirs
    SetEnvVar "OPENSSL_HOME" "$opensslHome"
    if uname -a |grep -q "Ubuntu"; then
        echo "export LD_LIBRARY_PATH=$opensslHome/lib:$LD_LIBRARY_PATH" >> ~/.bash_profile
    else
        echo "export LD_LIBRARY_PATH=$opensslHome/lib:$LD_LIBRARY_PATH" >> ~/.bashrc
    fi

elif [ "$os" == "macos" -o "$os" == "macos-universal" ]; then
    # Below target location has been hard coded into Coin.
    # QTQAINFRA-1195
    openssl_install_dir=/usr/local/openssl-$version
    opensslTargetLocation="/usr/local/opt/openssl"

    commonFlags="no-tests shared no-ssl3-method enable-ec_nistp_64_gcc_128 -Wa,--noexecstack"

    opensslBuild="${opensslHome}-build"
    opensslDestdir="${opensslHome}-destdir"
    mkdir -p $opensslBuild

    if [ "$os" == "macos-universal" ]; then
        archs="x86_64 arm64"
    else
        archs="x86_64"
    fi

    for arch in $archs; do
        cd $opensslBuild
        echo "Configuring OpenSSL for $arch"
        mkdir $arch && cd $arch
        $opensslSource/Configure --prefix=$openssl_install_dir $commonFlags darwin64-$arch-cc

        echo "Building OpenSSL for $arch"
        make --silent >> /tmp/openssl_make.log 2>&1

        echo "Installing OpenSSL for $arch"
        if [ "$os" == "macos-universal" ]; then
            destdir="$opensslDestdir/$arch"
        else
            destdir=""
        fi
        # shellcheck disable=SC2024
        sudo make --silent install DESTDIR=$destdir >> /tmp/openssl_make_install.log 2>&1
    done

    if [ "$os" == "macos-universal" ]; then
        echo "Making universal OpenSSL package"
        # shellcheck disable=SC2024
        sudo ${BASH_SOURCE%/*}/../macos/makeuniversal.sh "$opensslDestdir/x86_64" $opensslDestdir/arm64
    fi

    path=$(echo "$opensslTargetLocation" | sed -E 's/(.*)\/.*$/\1/')
    sudo mkdir -p "$path"
    sudo ln -s $openssl_install_dir $opensslTargetLocation

    SetEnvVar "PATH" "\"$opensslTargetLocation/bin:\$PATH\""
    SetEnvVar "MANPATH" "\"$opensslTargetLocation/share/man:\$MANPATH\""

    SetEnvVar "OPENSSL_DIR" "\"$openssl_install_dir\""
    SetEnvVar "OPENSSL_INCLUDE" "\"$openssl_install_dir/include\""
    SetEnvVar "OPENSSL_LIB" "\"$openssl_install_dir/lib\""

    security find-certificate -a -p /Library/Keychains/System.keychain | sudo tee -a $opensslTargetLocation/ssl/cert.pem > /dev/null
    security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain | sudo tee -a $opensslTargetLocation/ssl/cert.pem > /dev/null
fi


echo "OpenSSL = $version" >> ~/versions.txt
