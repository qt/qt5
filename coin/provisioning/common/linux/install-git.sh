#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script install git from sources.
# Requires GCC and Perl to be in PATH.
set -ex

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

version="2.36.1"
officialUrl="https://github.com/git/git/archive/refs/tags/v$version.tar.gz"
cachedUrl="http://ci-files01-hki.ci.qt.io/input/git/git-$version.tar.gz"
targetFile="/tmp/git-$version.tar.gz"
sha="a17c11da2968f280a13832d97f48e9039edac354"
DownloadURL "$cachedUrl" "$officialUrl" "$sha" "$targetFile"
sourceDir="/tmp/git-$version-source"
mkdir "$sourceDir"
tar -xzf "$targetFile" -C "$sourceDir"

cd "$sourceDir/git-$version"
installDir="$HOME/git"
make configure
./configure --prefix="$installDir"
make all
sudo make install

SetEnvVar "PATH" "\"$installDir/bin:\$PATH\""

"$installDir/bin/git" --version
