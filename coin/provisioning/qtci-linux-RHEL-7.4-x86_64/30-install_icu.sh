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

# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"

set -ex

# This script will install ICU

icuVersion="56.1"
icuLocation="/usr/lib64"
sha1="6dd9ca6b185681a7ddc4bb94fd7fced27647a21c"
baseBinaryPackageURL="http://ci-files01-hki.intra.qt.io/input/icu/$icuVersion/icu-linux-g++-Rhel7.2-x64.7z"
baseBinaryPackageExternalURL="http://master.qt.io/development_releases/prebuilt/icu/prebuilt/$icuVersion/icu-linux-g++-Rhel7.2-x64.7z"

sha1Dev="bffde26cdea752bee0edd281820c57f1adac3864"
develPackageURL="http://ci-files01-hki.intra.qt.io/input/icu/$icuVersion/icu-linux-g++-Rhel7.2-x64-devel.7z"
develPackageExternalURL="http://master.qt.io/development_releases/prebuilt/icu/prebuilt/$icuVersion/icu-linux-g++-Rhel7.2-x64-devel.7z"

echo "Installing custom ICU $icuVersion $sha1 packages on RHEL to $icuLocation"

targetFile=$(mktemp)
DownloadURL "$baseBinaryPackageURL" "$baseBinaryPackageExternalURL" "$sha1" "$targetFile"
sudo 7z x -y -o/usr/lib64 "$targetFile"
sudo rm "$targetFile"

echo "Installing custom ICU devel packages on RHEL"

tempDir=$(mktemp -d)

targetFile=$(mktemp)
DownloadURL "$develPackageURL" "$develPackageExternalURL" "$sha1Dev" "$targetFile"
7z x -y -o"$tempDir" "$targetFile"

sudo cp -a "$tempDir"/lib/* /usr/lib64
sudo cp -a "$tempDir"/* /usr/

sudo rm "$targetFile"
sudo rm -fr "$tempDir"

sudo /sbin/ldconfig

echo "ICU = $icuVersion" >> ~/versions.txt
