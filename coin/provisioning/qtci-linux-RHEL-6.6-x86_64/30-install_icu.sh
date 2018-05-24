#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2018 The Qt Company Ltd.
## Contact: http://www.qt.io/licensing/
##
## This file is part of the test suite of the Qt Toolkit.
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

# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"

# This script installs the right ICU version

set -ex
icuVersion="56.1"
icuLocation="/usr/lib64"
sha1="f2eab775c04ce5f3bdae6c47d06b62158b5d6753"

function Install7ZPackageFromURL {
    url=$1
    urlExt=$2
    expectedSha1=$3
    targetDirectory=$4

    targetFile=$(mktemp)
    DownloadURL "$url" "$urlExt" "$expectedSha1" "$targetFile"
    sudo /usr/local/bin/7z x -yo"$targetDirectory" "$targetFile"
    rm "$targetFile"
}

echo "Installing custom ICU $icuVersion $sha1 packages on RHEL to $icuLocation"

baseBinaryPackageURL="http://ci-files01-hki.intra.qt.io/input/icu/$icuVersion/icu-linux-g++-Rhel6.6-x64.7z"
baseBinaryPackageExternalUrl="http://master.qt.io/development_releases/prebuilt/icu/prebuilt/$icuVersion/icu-linux-g++-Rhel6.6-x64.7z"
Install7ZPackageFromURL "$baseBinaryPackageURL" "$baseBinaryPackageExternalUrl" "$sha1" "/usr/lib64"

echo "Installing custom ICU devel packages on RHEL"

sha1Dev="82f8b216371b848b8d36ecec7fe7b6e9b0dba0df"
develPackageURL="http://ci-files01-hki.intra.qt.io/input/icu/$icuVersion/icu-linux-g++-Rhel6.6-x64-devel.7z"
develPackageExternalUrl="http://master.qt.io/development_releases/prebuilt/icu/prebuilt/$icuVersion/icu-linux-g++-Rhel6.6-x64-devel.7z"
tempDir=$(mktemp -d)
# shellcheck disable=SC2064
trap "sudo rm -fr $tempDir" EXIT
Install7ZPackageFromURL "$develPackageURL" "$develPackageExternalUrl" "$sha1Dev" "$tempDir"
sudo cp -a "$tempDir/lib"/* /usr/lib64
sudo cp -a "$tempDir"/* /usr/

sudo /sbin/ldconfig

# Storage version information to ~/versions.txt, which is used to print version information to provision log.
echo "ICU = $icuVersion" >> ~/versions.txt

