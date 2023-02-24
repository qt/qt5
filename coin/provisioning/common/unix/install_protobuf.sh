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

# This script will install Google's Protocal Buffers

version="21.9"
sha1="3226a0e49d048759b702ae524da79387c59f05cc"
internalUrl="http://ci-files01-hki.intra.qt.io/input/automotive_suite/protobuf-all-$version.zip"
externalUrl="https://github.com/protocolbuffers/protobuf/releases/download/v$version/protobuf-all-$version.zip"

targetDir="$HOME/protobuf-$version"
targetFile="$targetDir.zip"
DownloadURL "$internalUrl" "$externalUrl" "$sha1" "$targetFile"
unzip "$targetFile" -d "$HOME"
sudo rm "$targetFile"

# devtoolset is needed when running configuration
if uname -a |grep -qv "Darwin"; then
    export PATH="/opt/rh/devtoolset-7/root/usr/bin:$PATH"
fi

echo "Configuring and building protobuf"

installPrefix="/usr/local"
if uname -a |grep -q Darwin; then
    extraCMakeArgs="-DCMAKE_OSX_ARCHITECTURES=x86_64;arm64 -DCMAKE_OSX_DEPLOYMENT_TARGET=11"
    SetEnvVar PATH "\$PATH:$installPrefix/bin"
fi

buildDir="$HOME/build-protobuf-$version"
mkdir "$buildDir"
cd "$buildDir"
cmake $targetDir -G"Ninja Multi-Config" \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_INSTALL_PREFIX=$installPrefix \
    $extraCMakeArgs \
    -Dprotobuf_BUILD_TESTS=OFF \
    -Dprotobuf_BUILD_EXAMPLES=OFF \
    -Dprotobuf_BUILD_PROTOC_BINARIES=ON \
    -DBUILD_SHARED_LIBS=OFF \
    -Dprotobuf_WITH_ZLIB=OFF \
    -DCMAKE_CONFIGURATION_TYPES="Release;Debug;RelWithDebugInfo" \
    -DCMAKE_CROSS_CONFIGS=all \
    -DCMAKE_DEFAULT_CONFIGS=all
ninja all:all
sudo env "PATH=$PATH" ninja install:all

# Refresh shared library cache if OS isn't macOS
if uname -a |grep -qv "Darwin"; then
    sudo ldconfig
fi

sudo rm -r "$targetDir"
sudo rm -r "$buildDir"
