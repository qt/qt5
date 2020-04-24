#!/bin/sh

echo "Unload notificationcenterui.plist"
launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist

echo "Remove 32-bit warnings"
rm ~/Library/Preferences/com.apple.coreservices.uiagent.plist
