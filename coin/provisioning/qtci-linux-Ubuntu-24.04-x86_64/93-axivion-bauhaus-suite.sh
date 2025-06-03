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
sourceFile="http://ci-files01-hki.ci.qt.io/input/axivion/bauhaus-suite-7_9_1-x86_64-gnu_linux.tar.gz"
targetFile="bauhaus-suite-7_9_1-x86_64-gnu_linux.tar.gz"
sha1="43d18d55087ce02009b850553405af55ba4e37e2"
cd "$HOME"
DownloadAndExtract "$sourceFile" "$sha1" "$targetFile" "$HOME"

mkdir "$HOME/.bauhaus"
cd "$HOME/.bauhaus"
wget http://ci-files01-hki.ci.qt.io/input/axivion/QT_11427439_2025-10-07.key
cd "$HOME"

#Axivion configuration
cp -r "${BASH_SOURCE%/*}/../common/linux/axivion/"  "$HOME/"

echo "Axivion Bauhaus Suite = 7.9.1" >> ~/versions.txt
