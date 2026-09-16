#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# This script modified system settings for automated use

targetFile="$HOME/vncpw.txt"

# Fetch password
curl --retry 5 --retry-delay 10 --retry-max-time 60 "http://ci-files01-hki.ci.qt.io/input/semisecure/vncpw.txt" -o "$targetFile"
shasum "$targetFile" |grep "a795fccaa8f277e62ec08e6056c544b8b63924a0"

{ VNCPassword=$(cat "$targetFile"); } 2> /dev/null
NTS_IP=10.212.2.216

echo "Disable Screensaver"
# For current session
defaults -currentHost write com.apple.screensaver idleTime 0

echo "Disable sleep"
sudo pmset sleep 0 displaysleep 0

# For session after a reboot
mkdir -p "$HOME/Library/LaunchAgents"
sudo tee -a "$HOME/Library/LaunchAgents/no-screensaver.plist" <<EOT
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">

<plist version="1.0">
    <dict>
        <key>Label</key>
        <string>org.qt.io.screensaver_disable</string>
        <key>ProgramArguments</key>
        <array>
            <string>defaults</string>
            <string>-currentHost</string>
            <string>write</string>
            <string>com.apple.screensaver</string>
            <string>idleTime</string>
            <string>0</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
    </dict>
</plist>
EOT

defaults write com.apple.screensaver askForPassword -int 0

echo "Set keyboard type rates and delays"
# normal minimum is 15 (225 ms)
defaults write -g InitialKeyRepeat -int 15
# normal minimum is 2 (30 ms)
defaults write -g KeyRepeat -int 2

set +x
echo "Enable remote desktop sharing"
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -clientopts -setvnclegacy -vnclegacy yes -clientopts -setvncpw -vncpw "$VNCPassword" -restart -agent -privs -all
set -x

echo "Set Network Test Server address to $NTS_IP in /etc/hosts"
echo "$NTS_IP    qt-test-server qt-test-server.qt-test-net" | sudo tee -a /etc/hosts

sudo systemsetup settimezone GMT
sudo systemsetup setusingnetworktime on
sudo rm -f "$targetFile"

# Enable automount for nfs shares
sudo sed -i'.orig' -e 's:^#/net:/net:' -e 's:hidefromfinder,nosuid:hidefromfinder,nosuid,locallocks,nocallback:' /etc/auto_master || sudo curl -o /etc/auto_master http://ci-files01-hki.ci.qt.io/input/mac/arm/auto_master
sudo automount -cv

# Disable multicast advertisements
sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true

# Enable Use keyboard navigation to move focus between controls
defaults write -g AppleKeyboardUIMode -int 2
