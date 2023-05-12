#!/usr/bin/env bash
# Copyright (C) 2018 The Qt Company Ltd.
# Copyright (C) 2020 Konstantin Tokarev <annulen@yandex.ru>
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

# This script will install dwz 0.13 - optimization tool for DWARF debug info

version="0.13"
sha1="21e6d5878bb84ac6c9ad07b00ed248d8c547bc7d"
internalUrl="http://ci-files01-hki.ci.qt.io/input/centos/dwz-$version.tar.xz"
externalUrl="https://www.sourceware.org/ftp/dwz/releases/dwz-$version.tar.xz"

targetDir="$HOME/dwz"
targetFile="$HOME/dwz-$version.zip"
DownloadURL "$internalUrl" "$externalUrl" "$sha1" "$targetFile"
tar -xJf "$targetFile" -C "$HOME"
sudo rm "$targetFile"

# devtoolset is needed when running configuration in RedHat
if uname -a |grep -q "el7"; then
    export PATH="/opt/rh/devtoolset-4/root/usr/bin:$PATH"
fi

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
