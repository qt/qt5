
#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2020 The Qt Company Ltd.
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
    officialUrl="ftp://ftp.mpi-sb.mpg.de/pub/gnu/mirror/gcc.gnu.org/pub/gcc/releases/gcc-$version/$sourceFile"

    targetFile="$tmpFolder/$sourceFile"
    buildFolder="$HOME/gcc_build"

    echo "Fetching prebuilt GCC."
    curl --fail -L --retry 5 --retry-delay 5 -o "$prebuiltTarget" "$prebuiltGCC" || (
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
