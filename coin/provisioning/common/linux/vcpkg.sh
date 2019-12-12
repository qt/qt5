#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
## Contact: https://www.qt.io/licensing/
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

set -ex

source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

# This script installs VcPkg. It is used to provide third-party libraries when cross-compiling
# for example for Emscripten or Android.

# Refresh to make sure we have the EMSCRIPTEN environment variable, needed for the vcpkg wasm build.
source ~/.bashrc

source "${BASH_SOURCE%/*}/../shared/vcpkg_version.txt"

officialUrl="https://codeload.github.com/tronical/vcpkg/tar.gz/$vcpkg_version"
targetFile="vcpkg.tar.gz"
targetFolder="$HOME/vcpkg"

wget --tries=5 --waitretry=5 --progress=dot:giga --output-document="$targetFile" "$officialUrl"

if [ ! -d "${targetFolder}" ]; then
    mkdir -p $targetFolder
fi

tar -C $targetFolder --strip-components=1 -xvzf $targetFile
rm -rf $targetFile

SetEnvVar "VCPKG_ROOT" "$targetFolder"

cd $targetFolder
./bootstrap-vcpkg.sh

./vcpkg install --triplet arm-android @qt-packages-android.txt
./vcpkg install --triplet arm64-android @qt-packages-android.txt
./vcpkg install --triplet x86-android @qt-packages-android.txt
./vcpkg install --triplet x64-android @qt-packages-android.txt

rm -rf packages buildtrees downloads

echo "VCPKG = $vcpkg_version" >> ~/versions.txt
