#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script will install ninja binary

# shellcheck source=./../unix/InstallFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../unix/InstallFromCompressedFileFromURL.sh"

version="1.10.2"
internalUrl="http://ci-files01-hki.ci.qt.io/input/mac/ninja-mac_v${version}.zip"
externalUrl="https://github.com/ninja-build/ninja/releases/download/v${version}/ninja-mac.zip"
SHA1="95d0ca5e7c67ab7181c87e6a6ec59d11b1ff2d30"
DestDir="/usr/local/bin/"

InstallFromCompressedFileFromURL "$internalUrl" "$externalUrl" "$SHA1" "$DestDir" ""

echo "Ninja = $version" >> ~/versions.txt
