#!/usr/bin/env bash
# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"
# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"

version="1.18.1"
internalUrl="http://ci-files01-hki.ci.qt.io/input/bundletool/bundletool-all-$version.jar"
externalUrl="https://github.com/google/bundletool/releases/download/$version/bundletool-all-$version.jar"
sha256="675786493983787ffa11550bdb7c0715679a44e1643f3ff980a529e9c822595c"
targetFile="$HOME/bundletool"
installPrefix="/opt/bundletool"

DownloadURL "$internalUrl" "$externalUrl" "$sha256" "$targetFile"


sudo mkdir -p "$installPrefix"
sudo mv "$targetFile" "$installPrefix/bundletool"

SetEnvVar "Bundletool_EXECUTABLE" "$installPrefix/bundletool"

echo "bundletool = $version" >> ~/versions.txt
