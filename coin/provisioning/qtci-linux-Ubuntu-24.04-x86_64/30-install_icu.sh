#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"

set -ex

# This script will install ICU

icuVersion="73.2"
icuLocationLib="/opt/icu/lib64"
icuLocationInclude="/opt/icu/include"
sha1="5699987afcceb0390e52fb860bb3b4ab8b39cabe"
baseBinaryPackageURL="http://ci-files01-hki.ci.qt.io/input/icu/$icuVersion/icu-linux-g++-Ubuntu22.04-x64.7z"
baseBinaryPackageExternalURL="http://master.qt.io/development_releases/prebuilt/icu/prebuilt/$icuVersion/icu-linux-g++-Ubuntu22.04-x64.7z"

sha1Dev="6b9da2fa5fd88db88e9957ee5e3cf9dbcd08fe6b"
develPackageURL="http://ci-files01-hki.ci.qt.io/input/icu/$icuVersion/icu-linux-g++-Ubuntu22.04-x64-devel.7z"
develPackageExternalURL="http://master.qt.io/development_releases/prebuilt/icu/prebuilt/$icuVersion/icu-linux-g++-Ubuntu22.04-x64-devel.7z"

echo "Installing custom ICU $icuVersion $sha1 packages on CentOS to $icuLocationLib"

targetFile=$(mktemp)
sudo mkdir -p "$icuLocationLib"
sudo mkdir -p "$icuLocationInclude"
DownloadURL "$baseBinaryPackageURL" "$baseBinaryPackageExternalURL" "$sha1" "$targetFile"
sudo 7z x -y -o$icuLocationLib "$targetFile"
sudo rm "$targetFile"

echo "Installing custom ICU devel packages on CentOS"

tempDir=$(mktemp -d)

targetFile=$(mktemp)
DownloadURL "$develPackageURL" "$develPackageExternalURL" "$sha1Dev" "$targetFile"
7z x -y -o"$tempDir" "$targetFile"

sudo cp -a "$tempDir"/lib/* "$icuLocationLib"
sudo cp -a "$tempDir"/* /opt/icu/

sudo rm "$targetFile"
sudo rm -fr "$tempDir"

sudo /sbin/ldconfig

echo "ICU = $icuVersion" >> ~/versions.txt
