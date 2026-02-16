#!/usr/bin/env bash

# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"

set -ex

# This script will install ICU

icuVersion="73.2"
icuLocation="/usr/lib64"
sha1="d2bbb7b2a9a9ee00dba5cc6a68137f6c8a98c27e"
baseBinaryPackageURL="http://ci-files01-hki.ci.qt.io/input/icu/$icuVersion/icu-linux-g++-Rhel8.6-x64.7z"
baseBinaryPackageExternalURL="http://master.qt.io/development_releases/prebuilt/icu/prebuilt/$icuVersion/icu-linux-g++-Rhel8.6-x64.7z"

sha1Dev="edc9cba31ffeac28bf7360c52b85b5e4d2f39043"
develPackageURL="http://ci-files01-hki.ci.qt.io/input/icu/$icuVersion/icu-linux-g++-Rhel8.6-x64-devel.7z"
develPackageExternalURL="http://master.qt.io/development_releases/prebuilt/icu/prebuilt/$icuVersion/icu-linux-g++-Rhel8.6-x64-devel.7z"

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
