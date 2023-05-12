#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

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

    prebuiltGCC="http://ci-files01-hki.ci.qt.io/input/gcc/gcc-$version-prebuilt.tar.gz"
    prebuiltTarget="$tmpFolder/gcc-$version-prebuilt.tar.gz"
    installPrefix="/usr/local"

    suffixVersion=$(echo "$version" | cut -d "." -f1,2)
    sourceFile="gcc-$version.tar.xz"
    cachedUrl="http://ci-files01-hki.ci.qt.io/input/gcc/$sourceFile"
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
