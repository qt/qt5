#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Disable "Download newly available updates in the background" from App Store
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -boolean FALSE

# Disable "Install system data files and security updates" from App Store
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -boolean FALSE

# Disable "Automatic checks"
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool FALSE
