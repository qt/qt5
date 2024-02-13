#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Will install homebrew package manager for macOS.
#     WARNING: Requires commandlinetools


set -e

. "$(dirname "$0")"/../common/unix/DownloadURL.sh

DownloadURL  \
    http://ci-files01-hki.ci.qt.io/input/mac/homebrew/d8f6c666d20a3d42e007ceec161a06651ad92ba331a24a3de62912edb129a522/install.sh  \
    http://ci-files01-hki.ci.qt.io/input/mac/homebrew/d8f6c666d20a3d42e007ceec161a06651ad92ba331a24a3de62912edb129a522/install.sh  \
    d8f6c666d20a3d42e007ceec161a06651ad92ba331a24a3de62912edb129a522  \
    /tmp/homebrew_install.sh

DownloadURL "http://ci-files01-hki.ci.qt.io/input/semisecure/sign/pw" "http://ci-files01-hki.ci.qt.io/input/semisecure/sign/pw" "aae58d00d0a1b179a09f21cfc67f9d16fb95ff36" "/Users/qt/pw"
{ pw=$(cat "/Users/qt/pw"); } 2> /dev/null
sudo chmod 755 /tmp/homebrew_install.sh
{ (echo "$pw" | /tmp/homebrew_install.sh); } 2> /dev/null
rm -f "/Users/qt/pw"

# No need to manually do `brew update`, the homebrew installer script does it.
### brew update
