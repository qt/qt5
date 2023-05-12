#!/usr/bin/env bash
# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs XZ-Utils

# XZ-Utils are needed for uncompressing xz-compressed files

set -ex

# shellcheck source=../common/macos/InstallPKGFromURL.sh
source "${BASH_SOURCE%/*}/../common/macos/InstallPKGFromURL.sh"

PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/mac/macos_10.12_sierra/XZ.pkg"
AltUrl="http://sourceforge.net/projects/macpkg/files/XZ/5.0.7/XZ.pkg"
SHA1="f0c1f82ebcffe0bd4b8b57b6a77805db56b2de67"
DestDir="/"

InstallPKGFromURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$DestDir"

echo "XZ = 5.0.7" >> ~/versions.txt
