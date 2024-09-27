#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"

set -ex

# This script will install ICU

icuVersion="73.2"
icuLocationLib="/usr/local/lib"
icuLocationInclude="/usr/local/include"
sha1="82f3ed54fd7ea8ff469d9000164e4dc23378fc8c"
baseBinaryPackageURL="http://ci-files01-hki.ci.qt.io/input/icu/$icuVersion/icu-linux-g++-Ubuntu24.04-aarch64.7z"
baseBinaryPackageExternalURL="http://master.qt.io/development_releases/prebuilt/icu/prebuilt/$icuVersion/icu-linux-g++-Ubuntu24.04-aarch64.7z"

sha1Dev="37c2528df9d2b5cba1765fe8036e69b7c326a1e1"
develPackageURL="http://ci-files01-hki.ci.qt.io/input/icu/$icuVersion/icu-linux-g++-Ubuntu24.04-aarch64-devel.7z"
develPackageExternalURL="http://master.qt.io/development_releases/prebuilt/icu/prebuilt/$icuVersion/icu-linux-g++-Ubuntu24.04-aarch64-devel.7z"

echo "Installing custom ICU $icuVersion $sha1 packages on Ubuntu to $icuLocationLib"

targetFile=$(mktemp)
sudo mkdir -p "$icuLocationLib"
sudo mkdir -p "$icuLocationInclude"
DownloadURL "$baseBinaryPackageURL" "$baseBinaryPackageExternalURL" "$sha1" "$targetFile"
sudo 7z x -y -o$icuLocationLib "$targetFile"
sudo rm "$targetFile"

echo "Installing custom ICU devel packages on Ubuntu"

tempDir=$(mktemp -d)

targetFile=$(mktemp)
DownloadURL "$develPackageURL" "$develPackageExternalURL" "$sha1Dev" "$targetFile"
7z x -y -o"$tempDir" "$targetFile"

sudo cp -a "$tempDir"/lib/* "$icuLocationLib"
sudo cp -a "$tempDir"/include/* "$icuLocationInclude"

sudo rm "$targetFile"
sudo rm -fr "$tempDir"

sudo /sbin/ldconfig

echo "ICU = $icuVersion" >> ~/versions.txt
