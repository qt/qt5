#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Will install homebrew package manager for macOS.
#     WARNING: Requires commandlinetools


set -e

. "$(dirname "$0")"/../unix/DownloadURL.sh
. "$(dirname "$0")"/../unix/SetEnvVar.sh


DownloadURL  \
    http://ci-files01-hki.ci.qt.io/input/mac/homebrew/be699a568315f57b65519df576d7fc5840b8a5cc/install.sh  \
    https://raw.githubusercontent.com/Homebrew/install/be699a568315f57b65519df576d7fc5840b8a5cc/install  \
    f20e4a577f0cafbab5a44b4d239886d725b3b985  \
    /tmp/homebrew_install.sh

DownloadURL "http://ci-files01-hki.ci.qt.io/input/semisecure/sign/pw" "http://ci-files01-hki.ci.qt.io/input/semisecure/sign/pw" "aae58d00d0a1b179a09f21cfc67f9d16fb95ff36" "/Users/qt/pw"
{ pw=$(cat "/Users/qt/pw"); } 2> /dev/null
sudo chmod 755 /tmp/homebrew_install.sh
{ (echo "$pw" | /tmp/homebrew_install.sh); } 2> /dev/null
rm -f "/Users/qt/pw"

# No need to manually do `brew update`, the homebrew installer script does it.
### brew update

SetEnvVar "PATH" "\$PATH:/opt/homebrew/bin"
