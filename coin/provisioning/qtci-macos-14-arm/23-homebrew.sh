#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Will install homebrew package manager for macOS.
#     WARNING: Requires commandlinetools


set -e

BASEDIR=$(dirname "$0")
"$BASEDIR/../common/macos/homebrew_for_arm_mac.sh"
# Can we force reading bash env this late?
echo "if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi" >> .profile
