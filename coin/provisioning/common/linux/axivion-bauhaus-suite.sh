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
sourceFile="http://ci-files01-hki.ci.qt.io/input/axivion/bauhaus-suite-7_7_4-x86_64-gnu_linux.tar.gz"
targetFile="bauhaus-suite-7_7_4-x86_64-gnu_linux.tar.gz"
sha1="df17ac0521864a7f1c0b5b3bfded1817cbf47bae"
cd "$HOME"
DownloadAndExtract "$sourceFile" "$sha1" "$targetFile" "$HOME"

mkdir "$HOME/.bauhaus"
cd "$HOME/.bauhaus"
wget http://ci-files01-hki.ci.qt.io/input/axivion/Qt_Evaluation_QSR_INTERN_20250118.key
cd "$HOME"

#Axivion configuration
configurationFile="http://ci-files01-hki.ci.qt.io/input/axivion/axivion_config_771_new.tar.gz"
configurationTargetFile="axivion_config.tar.gz"
configSha1="db77f376e0b3ee0f7a74701790d1c8abe792bebe"
DownloadAndExtract "$configurationFile" "$configSha1" "$configurationTargetFile" "$HOME"

echo "Axivion Bauhaus Suite = 7.7.4" >> ~/versions.txt
