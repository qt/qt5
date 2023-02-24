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

# This script installs gRPC from sources.
set -ex

# shellcheck source=./DownloadURL.sh
source "${BASH_SOURCE%/*}/DownloadURL.sh"
# shellcheck source=./SetEnvVar.sh
source "${BASH_SOURCE%/*}/SetEnvVar.sh"

# Extract cmake path from the environment
if uname -a |grep -q "Ubuntu"; then
    if lsb_release -a |grep "Ubuntu 22.04"; then
        source ~/.bash_profile
    else
        source ~/.profile
    fi
else
    source ~/.bashrc
fi

version="1.50.1"
sha1="be1b0c3dbfbc9714824921f50dffb7cf044da5ab"
internalUrl="http://ci-files01-hki.intra.qt.io/input/automotive_suite/grpc-all-$version.zip"
externalUrl=""
installPrefix="$HOME/install-grpc-$version"

targetDir="$HOME/grpc-$version"
targetFile="$targetDir.zip"
DownloadURL "$internalUrl" "$externalUrl" "$sha1" "$targetFile"
unzip -q "$targetFile" -d "$HOME"
sudo rm "$targetFile"

# devtoolset is needed when running configuration
if uname -a |grep -qv "Darwin"; then
    export PATH="/opt/rh/devtoolset-7/root/usr/bin:$PATH"
fi

if uname -a |grep -q Darwin; then
    extraCMakeArgs="-DCMAKE_OSX_ARCHITECTURES=x86_64;arm64 -DCMAKE_OSX_DEPLOYMENT_TARGET=11"
    SetEnvVar PATH "\$PATH:$installPrefix/bin"
fi

# MacOS
if [[ -n "$OPENSSL_DIR" ]]; then
    extraOpenSslArg=-DOPENSSL_ROOT_DIR=$OPENSSL_DIR
# Linux
elif [[ -n "$OPENSSL_HOME" ]]; then
    extraOpenSslArg=-DOPENSSL_ROOT_DIR=$OPENSSL_HOME
fi

echo "Configuring and building gRPC"

buildDir="$HOME/build-grpc-$version"
mkdir -p "$buildDir"
cd "$buildDir"
cmake $targetDir -G"Ninja Multi-Config" \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_CONFIGURATION_TYPES="Release;Debug;RelWithDebugInfo" \
    -DCMAKE_INSTALL_PREFIX=$installPrefix \
    $extraCMakeArgs \
    $extraOpenSslArg \
    -DgRPC_BUILD_TESTS=OFF \
    -DgRPC_PROTOBUF_PROVIDER="package" \
    -DgRPC_SSL_PROVIDER="package" \
    -DgRPC_ZLIB_PROVIDER="package"
ninja all

sudo env "PATH=$PATH" ninja install
# Refresh shared library cache if OS isn't macOS
if uname -a |grep -qv "Darwin"; then
    sudo ldconfig
fi

SetEnvVar "gRPC_ROOT" "$installPrefix"
SetEnvVar "absl_ROOT" "$installPrefix"

sudo rm -rf "$targetDir"
sudo rm -rf "$buildDir"
