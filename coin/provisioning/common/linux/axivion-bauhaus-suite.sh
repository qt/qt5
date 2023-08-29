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
    tar -xzvf $file

    rm -rf $file
}


# Axivion Bauhaus Suite
sourceFile="http://ci-files01-hki.ci.qt.io/input/axivion/bauhaus-suite-7_6_0-wavefront-2023-03-16-x86_64-gnu_linux.tar.gz"
targetFile="bauhaus-suite-7_6_0-wavefront-2023-03-16-x86_64-gnu_linux.tar.gz"
sha1="20bfa8872b90ff11394098a833d536229425535e"
cd $HOME
DownloadAndExtract "$sourceFile" "$sha1" "$targetFile" "$HOME"

mkdir $HOME/.bauhaus
cd "$HOME/.bauhaus"
wget http://ci-files01-hki.ci.qt.io/input/axivion/Qt_Evaluation_20231231.key
cd $HOME

#Axivion configuration
configurationFile="http://ci-files01-hki.ci.qt.io/input/axivion/axivion_config.tar.gz"
configurationTargetFile="axivion_config.tar.gz"
configSha1="f3aa53f253fa00c7f3fa64e9fe55aa7f93bc5377"
DownloadAndExtract "$configurationFile" "$configSha1" "$configurationTargetFile" "$HOME"

echo "Axivion Bauhaus Suite = 7.6.0_wavefront-2022-03-16" >> ~/versions.txt
