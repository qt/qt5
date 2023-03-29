#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs flite from sources.
# Requires make, GCC and git to be in PATH.
set -ex

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

repName="flite"
gitUrl="https://github.com/festvox/$repName.git"
tmpdir="/tmp"
repDir="$tmpdir/$repName"
prefix="/usr"
rm -rf "$repDir"
cd "$tmpdir"
git clone -q "$gitUrl"
cd "$repDir"
git checkout -q v2.2
./configure --with-pic --enable-shared --prefix="$prefix" > /dev/null
make "-j$(nproc)" > /dev/null && sudo make install > /dev/null
rm -rf "$repDir"
