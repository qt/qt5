#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2018 The Qt Company Ltd.
## Copyright (C) 2020 Konstantin Tokarev <annulen@yandex.ru>
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

# This script will install dwz 0.13 - optimization tool for DWARF debug info

version="0.13"
sha1="21e6d5878bb84ac6c9ad07b00ed248d8c547bc7d"
internalUrl="http://ci-files01-hki.intra.qt.io/input/rhel7/dwz-$version.tar.xz"
externalUrl="https://www.sourceware.org/ftp/dwz/releases/dwz-$version.tar.xz"

targetDir="$HOME/dwz"
targetFile="$HOME/dwz-$version.zip"
DownloadURL "$internalUrl" "$externalUrl" "$sha1" "$targetFile"
tar -xJf "$targetFile" -C "$HOME"
sudo rm "$targetFile"

# devtoolset is needed when running configuration
export PATH="/opt/rh/devtoolset-4/root/usr/bin:$PATH"

installPrefix="/opt/dwz-$version"

echo "Configuring and building dwz"
cd "$targetDir"
# dwz uses plain makefile instead of autotools, so it works a bit unconventionally
./configure
make -j5
sudo make install prefix=$installPrefix

sudo rm -r "$targetDir"

SetEnvVar "PATH" "$installPrefix/bin:\$PATH"

echo "dwz = $version" >> ~/versions.txt
