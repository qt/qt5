#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs gRPC from sources.
set -ex

# shellcheck source=./DownloadURL.sh
source "${BASH_SOURCE%/*}/DownloadURL.sh"
# shellcheck source=./SetEnvVar.sh
source "${BASH_SOURCE%/*}/SetEnvVar.sh"

# Extract cmake path from the environment
if uname -a |grep -q "Ubuntu"; then
    if lsb_release -a |grep -q "Ubuntu 22.04"; then
# shellcheck source=/dev/null
        source ~/.bash_profile
    else
# shellcheck source=/dev/null
        source ~/.profile
    fi
else
# shellcheck source=/dev/null
    source ~/.bashrc
fi

version="1.50.1"
sha1="be1b0c3dbfbc9714824921f50dffb7cf044da5ab"
internalUrl="http://ci-files01-hki.ci.qt.io/input/automotive_suite/grpc-all-$version.zip"
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
    extraCMakeArgs=("-DCMAKE_OSX_ARCHITECTURES=x86_64;arm64" -DCMAKE_OSX_DEPLOYMENT_TARGET=12)
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
cmake "$targetDir" -G"Ninja Multi-Config" \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_CONFIGURATION_TYPES="Release;Debug;RelWithDebugInfo" \
    -DCMAKE_INSTALL_PREFIX="$installPrefix" \
    "${extraCMakeArgs[@]}" \
    "$extraOpenSslArg" \
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
