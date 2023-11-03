#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"

set -ex

# This script will install ICU

icuVersion="73.2"
icuLocationLib="/usr/local"
sha1="84b4acc6062a75d795e272d222cc682cd2f33cdd"

sha1Dev="94c27ce0c7cbd310e7746d08f54bb7318e297c31"
develPackageURL="http://ci-files01-hki.ci.qt.io/input/icu/$icuVersion/icu-linux-g++-Debian11.6-aarch64-devel.7z"
develPackageExternalURL="http://master.qt.io/development_releases/prebuilt/icu/prebuilt/$icuVersion/icu-linux-g++-Debian11.6-aarch64-devel.7z"

echo "Installing custom ICU $icuVersion $sha1 packages on Debian to $icuLocationLib"

tempDir=$(mktemp -d)

targetFile=$(mktemp)
DownloadURL "$develPackageURL" "$develPackageExternalURL" "$sha1Dev" "$targetFile"
7z x -y -o"$tempDir" "$targetFile"

sudo cp -a "$tempDir"/* "$icuLocationLib"

sudo rm "$targetFile"
sudo rm -fr "$tempDir"

sudo /sbin/ldconfig

echo "ICU = $icuVersion" >> ~/versions.txt
