#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Dock autohide interfers with window sizes and mouse cursor/focus

set -e
sudo defaults write com.apple.dock autohide -bool false; killall Dock
