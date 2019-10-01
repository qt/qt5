#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2018 The Qt Company Ltd.
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

# shellcheck source=./DownloadURL.sh
source "${BASH_SOURCE%/*}/DownloadURL.sh"
# shellcheck source=./SetEnvVar.sh
source "${BASH_SOURCE%/*}/SetEnvVar.sh"

# This script will install Google's Protocal Buffers which is needed by Automotive Suite

version="3.6.1"
sha1="44b8ba225f3b4dc45fb56d5881ec6a91329802b6"
internalUrl="http://ci-files01-hki.intra.qt.io/input/automotive_suite/protobuf-all-$version.zip"
externalUrl="https://github.com/protocolbuffers/protobuf/releases/download/v$version/protobuf-all-$version.zip"

targetDir="$HOME/protobuf-$version"
targetFile="$targetDir.zip"
DownloadURL "$internalUrl" "$externalUrl" "$sha1" "$targetFile"
unzip "$targetFile" -d "$HOME"
sudo rm "$targetFile"

# devtoolset is needed when running configuration
if uname -a |grep -qv "Darwin"; then
    export PATH="/opt/rh/devtoolset-4/root/usr/bin:$PATH"
fi

echo "Configuring and building protobuf"
cd "$targetDir"
if uname -a |grep -q Darwin; then
    ./configure --prefix "$(xcrun --sdk macosx --show-sdk-path)/usr/local"
    SetEnvVar PATH "\$PATH:$(xcrun --sdk macosx --show-sdk-path)/usr/local/bin"
else
    ./configure
fi
make -j5
sudo make install

# Refresh shared library cache if OS isn't macOS
if uname -a |grep -qv "Darwin"; then
    sudo ldconfig
fi

sudo rm -r "$targetDir"
