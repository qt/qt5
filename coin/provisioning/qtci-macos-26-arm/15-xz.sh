#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs XZ-Utils

# XZ-Utils are needed for uncompressing xz-compressed files

# pkg was self builded.
# wget https://downloads.sourceforge.net/project/lzmautils/xz-5.2.5.tar.gz
# tar -xzf xz-5.2.5.tar.gz -C /tmp
# cd /tmp/xz-5.2.5
# ./configure
# make
# ./configure prefix=/tmp/destination_root
# make install
# cd /tmp
# pkgbuild --root destination_root --identifier io.qt.xz.pkg xz-arm64.pkg

set -ex

# shellcheck source=../common/macos/InstallPKGFromURL.sh
source "${BASH_SOURCE%/*}/../common/macos/InstallPKGFromURL.sh"
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/mac/macos_11.0_big_sur_arm/xz-arm64.pkg"
# SourceUrl="https://tukaani.org/xz/xz-5.2.5.tar.gz"

SHA1="1afc327965d4af33399ae28f22c4b8e5a9e98dc2"
DestDir="/"

InstallPKGFromURL "$PrimaryUrl" "$PrimaryUrl" "$SHA1" "$DestDir"

echo "XZ = 5.2.5" >> ~/versions.txt
