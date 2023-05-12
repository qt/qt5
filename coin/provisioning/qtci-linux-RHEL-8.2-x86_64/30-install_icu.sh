#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"

set -ex

# This script will install ICU

icuVersion="56.1"
icuLocation="/usr/lib64"
sha1="6dd9ca6b185681a7ddc4bb94fd7fced27647a21c"
baseBinaryPackageURL="http://ci-files01-hki.ci.qt.io/input/icu/$icuVersion/icu-linux-g++-Rhel7.2-x64.7z"
baseBinaryPackageExternalURL="http://master.qt.io/development_releases/prebuilt/icu/prebuilt/$icuVersion/icu-linux-g++-Rhel7.2-x64.7z"

sha1Dev="bffde26cdea752bee0edd281820c57f1adac3864"
develPackageURL="http://ci-files01-hki.ci.qt.io/input/icu/$icuVersion/icu-linux-g++-Rhel7.2-x64-devel.7z"
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
