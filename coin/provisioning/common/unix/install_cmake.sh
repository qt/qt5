#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
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

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

set -ex

# This script will install Cmake

version="e1af2489fda9129e735007a069fae018c4ab3431"
sha1="357ad8003b30ec23037b59b750b96a75e52f78bb"
internalUrl="http://ci-files01-hki.intra.qt.io/input/cmake/CMake-$version.zip"
externalUrl="https://codeload.github.com/Kitware/CMake/zip/$version"

targetDir="$HOME/CMake-$version"
targetFile="$targetDir.zip"
installFolder="$HOME"
cmakeHome="$HOME/cmake"
DownloadURL "$internalUrl" "$externalUrl" "$sha1" "$targetFile"
unzip "$targetFile" -d "$HOME"
sudo rm "$targetFile"

echo "Configuring and building cmake"
cd "$targetDir"
if uname -a |grep -q Darwin; then
    ./bootstrap --prefix="$(xcrun --sdk macosx --show-sdk-path)/usr/local"
    SetEnvVar PATH "\$PATH:$(xcrun --sdk macosx --show-sdk-path)/usr/local/bin"
else
    ./bootstrap --prefix="$cmakeHome"
    SetEnvVar "PATH" "$cmakeHome/bin:\$PATH"
fi
make
sudo make install

sudo rm -r "$targetDir"

echo "CMake = $version" >> ~/versions.txt
