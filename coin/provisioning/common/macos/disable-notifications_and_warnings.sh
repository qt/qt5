#!/bin/sh
#Copyright (C) 2023 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

echo "Unload notificationcenterui.plist"
launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist

echo "Remove 32-bit warnings"
rm -f ~/Library/Preferences/com.apple.coreservices.uiagent.plist
