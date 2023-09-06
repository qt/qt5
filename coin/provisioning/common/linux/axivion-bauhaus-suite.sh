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
sourceFile="http://ci-files01-hki.ci.qt.io/input/axivion/bauhaus-suite-7_6_2-x86_64-gnu_linux.tar.gz"
targetFile="bauhaus-suite-7_6_2-x86_64-gnu_linux.tar.gz"
sha1="a47891ec1a258240b72b1b5410413da900b30b14"
cd $HOME
DownloadAndExtract "$sourceFile" "$sha1" "$targetFile" "$HOME"

# Temporary patch for fixing qt rules
cd $HOME/bauhaus-suite/lib/scripts/bauhaus/rfg/dynamic
rm qt_support.py
wget http://ci-files01-hki.ci.qt.io/input/axivion/qt_support.py
cd $HOME
# Temporary patch ends

mkdir $HOME/.bauhaus
cd "$HOME/.bauhaus"
wget http://ci-files01-hki.ci.qt.io/input/axivion/Qt_Evaluation_20231231.key
cd "$HOME"

#Axivion configuration
configurationFile="http://ci-files01-hki.ci.qt.io/input/axivion/axivion_config_762.tar.gz"
configurationTargetFile="axivion_config.tar.gz"
configSha1="2c5ce2ed2f1a2e8fd8a6a2a07a12c9c7d9e90413"
DownloadAndExtract "$configurationFile" "$configSha1" "$configurationTargetFile" "$HOME"

echo "Axivion Bauhaus Suite = 7.6.2" >> ~/versions.txt
