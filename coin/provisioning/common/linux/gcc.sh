#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2021 The Qt Company Ltd.
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

# This script builds GCC from sources

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

set -ex

function InstallGCC() {
    version=$1
    priority=$2
    prebuiltSHA1=$3
    sourcesSHA1=$4

    tmpFolder="/tmp"

    prebuiltGCC="http://ci-files01-hki.intra.qt.io/input/gcc/gcc-$version-prebuilt.tar.gz"
    prebuiltTarget="$tmpFolder/gcc-$version-prebuilt.tar.gz"
    installPrefix="/usr/local"

    suffixVersion=$(echo "$version" | cut -d "." -f1,2)
    sourceFile="gcc-$version.tar.xz"
    cachedUrl="http://ci-files01-hki.intra.qt.io/input/gcc/$sourceFile"
    officialUrl="https://gcc.gnu.org/pub/gcc/releases/gcc-$version/gcc-$version.tar.xz"

    targetFile="$tmpFolder/$sourceFile"
    buildFolder="$HOME/gcc_build"

    echo "Fetching prebuilt GCC."
    DownloadURL "$prebuiltGCC" "" "$prebuiltSHA1" "$prebuiltTarget" || (
        echo "Fetching prebuilt GCC failed. Building from sources."
        DownloadURL "$cachedUrl" "$officialUrl" "$sourcesSHA1" "$targetFile"
    )

    if [ -f "$prebuiltTarget" ]; then
        echo "$prebuiltSHA1 *$prebuiltTarget" | sha1sum -c -
        sudo tar -xzf "$prebuiltTarget" -C "$installPrefix"
        rm -rf "$prebuiltTarget"
    else
        tar -C "$tmpFolder" -xJf "$targetFile"
        mkdir -p "$buildFolder"
        cd "$tmpFolder/gcc-$version"
        sudo "$tmpFolder/gcc-$version/contrib/download_prerequisites"
        cd "$buildFolder"
        "$tmpFolder/gcc-$version/configure" --disable-bootstrap --enable-languages=c,c++,lto --prefix="$installPrefix" --program-suffix="-$suffixVersion"
        make -j4
        sudo make install

        rm -rf "$targetFile"
        sudo rm -rf "$tmpFolder/gcc-$version"
    fi

    # openSUSE has update-alternatives under /usr/sbin and it has grouped the commands by means of master and slave links
    if [ -f "/usr/sbin/update-alternatives" ]; then
        sudo /usr/sbin/update-alternatives --install /usr/bin/gcc gcc "$installPrefix/bin/gcc${suffixVersion}" "$priority" \
                                           --slave /usr/bin/g++ g++ "$installPrefix/bin/g++${suffixVersion}" \
                                           --slave /usr/bin/cc cc "$installPrefix/bin/gcc${suffixVersion}" \
                                           --slave /usr/bin/c++ c++ "$installPrefix/bin/g++${suffixVersion}"
    else
        sudo /usr/bin/update-alternatives --install /usr/bin/gcc gcc "$installPrefix/bin/gcc-${suffixVersion}" "$priority"
        sudo /usr/bin/update-alternatives --install /usr/bin/g++ g++ "$installPrefix/bin/g++-${suffixVersion}" "$priority"
        sudo /usr/bin/update-alternatives --install /usr/bin/cc cc "$installPrefix/bin/gcc-${suffixVersion}" "$priority"
        sudo /usr/bin/update-alternatives --install /usr/bin/c++ c++ "$installPrefix/bin/g++-${suffixVersion}" "$priority"
    fi

    echo "/usr/local/lib64" | sudo tee /etc/ld.so.conf.d/gcc-libraries.conf
    echo "/usr/local/lib32" | sudo tee -a /etc/ld.so.conf.d/gcc-libraries.conf
    sudo ldconfig -v

    echo "GCC = $version" >> ~/versions.txt
}
