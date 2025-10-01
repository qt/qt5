#!/bin/bash
#Copyright (C) 2024 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs Axivion Bauhaus Suite tool.

set -ex

# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"

DownloadAndExtract () {
    url=$1
    sha=$2
    file=$3

    DownloadURL "$url" "$url" "$sha" "$file"
    tar -xzvf "$file"

    rm -rf "$file"
}


# Axivion Bauhaus Suite
version="7.10.5"
sourceFile="http://ci-files01-hki.ci.qt.io/input/axivion/bauhaus-suite-$version-x86_64-gnu_linux.tar.gz"
targetFile="bauhaus-suite.tar.gz"
sha1="59d996b3f66c928eb7063a8f66ec12eaf4e21318"
cd "$HOME"
DownloadAndExtract "$sourceFile" "$sha1" "$targetFile"

mkdir "$HOME/.bauhaus"
cd "$HOME/.bauhaus"
wget http://ci-files01-hki.ci.qt.io/input/axivion/QT_11427439_2026-12-31.key
cd "$HOME"

#Axivion configuration
cp -r "${BASH_SOURCE%/*}/../common/linux/axivion/"  "$HOME/"

echo "Axivion Bauhaus Suite = $version" >> ~/versions.txt
