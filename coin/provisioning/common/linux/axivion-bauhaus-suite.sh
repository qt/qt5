#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs Axivion Bauhaus Suite tool.

set -ex

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
# source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

DownloadAndExtract () {
    url=$1
    sha=$2
    file=$3

    DownloadURL "$url" "$url" "$sha" "$file"
    tar -xzvf "$file"

    rm -rf "$file"
}


# Axivion Bauhaus Suite
sourceFile="http://ci-files01-hki.ci.qt.io/input/axivion/bauhaus-suite-7_8_0-x86_64-gnu_linux.tar.gz"
targetFile="bauhaus-suite-7_8_0-x86_64-gnu_linux.tar.gz"
sha1="bae1a7091ab9582822bfcd00b826e07d9b467a04"
cd "$HOME"
DownloadAndExtract "$sourceFile" "$sha1" "$targetFile" "$HOME"

mkdir "$HOME/.bauhaus"
cd "$HOME/.bauhaus"
wget http://ci-files01-hki.ci.qt.io/input/axivion/Qt_Evaluation_QSR_INTERN_20250118.key
cd "$HOME"

#Axivion configuration
configurationFile="http://ci-files01-hki.ci.qt.io/input/axivion/axivion_config_780_2506.tar.gz"
configurationTargetFile="axivion_config.tar.gz"
configSha1="a27c4db94e8b875e756dc820259fffdd7afc19b6"
DownloadAndExtract "$configurationFile" "$configSha1" "$configurationTargetFile" "$HOME"

echo "Axivion Bauhaus Suite = 7.8.0" >> ~/versions.txt
