#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Will install homebrew package manager for macOS.
#     WARNING: Requires commandlinetools


set -e

. "$(dirname "$0")"/../common/unix/DownloadURL.sh


DownloadURL  \
    http://ci-files01-hki.ci.qt.io/input/mac/homebrew/a822f0d0f1838c07e86b356fcd2bf93c7a11c2aa/install.sh  \
    https://raw.githubusercontent.com/Homebrew/install/c744a716f9845988d01e6e238eee7117b8c366c9/install  \
    3210da71e12a699ab3bba43910a6d5fc64b92000  \
    /tmp/homebrew_install.sh

DownloadURL "http://ci-files01-hki.ci.qt.io/input/semisecure/sign/pw" "http://ci-files01-hki.ci.qt.io/input/semisecure/sign/pw" "aae58d00d0a1b179a09f21cfc67f9d16fb95ff36" "/Users/qt/pw"
{ pw=$(cat "/Users/qt/pw"); } 2> /dev/null
sudo chmod 755 /tmp/homebrew_install.sh
{ (echo "$pw" | /tmp/homebrew_install.sh); } 2> /dev/null
rm -f "/Users/qt/pw"

# No need to manually do `brew update`, the homebrew installer script does it.
### brew update

