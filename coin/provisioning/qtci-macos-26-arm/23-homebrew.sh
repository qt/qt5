#!/usr/bin/env bash
#Copyright (C) 2025 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

INSTALLTYPE="PKG"

BASEDIR=$(dirname "$0")
# Usage "$BASEDIR/../common/macos/homebrew.sh" "$INSTALLTYPE" "$HOMEBREW_VERSION" "$HOMEBREW_HASH"
# Specify HOMEBREW_VERSION and HOMEBREW_HASH only if defaults set in homebrew.sh are not suitable for this platform
"$BASEDIR/../common/macos/homebrew.sh" "$INSTALLTYPE"
