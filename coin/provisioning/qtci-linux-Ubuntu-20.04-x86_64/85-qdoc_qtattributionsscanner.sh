#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Provisions qdoc and qtattributionsscanner binaries; these are used for
# documentation testing without the need for a dependency to qttools.

set -e

# shellcheck source=../common/unix/check_and_set_proxy.sh
"${BASH_SOURCE%/*}/../common/unix/check_and_set_proxy.sh"
# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"

version="39fad60085501729985888d3f546c7b8d897a394"
sha1="b3bc413866951807fe2e87e84394cd6f69904718"
url="https://download.qt.io/development_releases/prebuilt/qdoc/qt/qdoc-qtattributionsscanner_${version//\./}-based-linux-Ubuntu20.04-gcc9.3-x86_64.7z"
url_cached="http://ci-files01-hki.ci.qt.io/input/qdoc/qt/qdoc-qtattributionsscanner_${version//\./}-based-linux-Ubuntu20.04-gcc9.3-x86_64.7z"

zip="/tmp/qdoc-qtattributionsscanner.7z"
destination="/opt/qt-doctools"

sudo mkdir -p "$destination"
sudo chmod 755 "$destination"
DownloadURL "$url_cached" "$url" "$sha1" "$zip"
if command -v 7zr &> /dev/null; then
    sudo 7zr x "$zip" "-o$destination/"
else
    sudo 7z x "$zip" "-o$destination/"
fi
sudo chown -R qt:users "$destination"
rm -rf "$zip"

echo -e "qdoc = $version\nqtattributionsscanner = $version" >> ~/versions.txt
