#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs Xcode
# Prerequisites: Have Xcode prefetched to local cache as xz compressed.
# This can be achieved by fetching Xcode_9.xip from Apple Store.
# Uncompress it with 'xar -xf Xcode_9.xip'
# Then get https://gist.githubusercontent.com/pudquick/ff412bcb29c9c1fa4b8d/raw/24b25538ea8df8d0634a2a6189aa581ccc6a5b4b/parse_pbzx2.py
# with which you can run 'python parse_pbzx2.py Content'.
# This will give you five files called "Content.part<00..05>.cpio.xz".
# Extract those that have the extension .xz with xz.
# "cat" together all the content files "cat file1, file2, file3, file4, file5 >file_new"
# Compress the new file with xz back to something like Xcode_9.xz
# Upload the file to temporary storage for this script to use.

set -ex

# shellcheck source=../common/macos/install_xcode.sh
source "${BASH_SOURCE%/*}/../common/macos/install_xcode.sh"

InstallXCode /net/ci-files01-hki.ci.qt.io/hdd/www/input/mac/macos_10.15_catalina/Xcode_12.4.xip 12.4
