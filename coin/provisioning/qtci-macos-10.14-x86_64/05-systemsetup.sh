#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
## Contact: http://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL21$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see http://www.qt.io/terms-conditions. For further
## information use the contact form at http://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 2.1 or version 3 as published by the Free
## Software Foundation and appearing in the file LICENSE.LGPLv21 and
## LICENSE.LGPLv3 included in the packaging of this file. Please review the
## following information to ensure the GNU Lesser General Public License
## requirements will be met: https://www.gnu.org/licenses/lgpl.html and
## http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
##
## As a special exception, The Qt Company gives you certain additional
## rights. These rights are described in The Qt Company LGPL Exception
## version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
##
## $QT_END_LICENSE$
##
#############################################################################

set -ex

# This script modified system settings for automated use

targetFile="$HOME/vncpw.txt"

# Fetch password
curl --retry 5 --retry-delay 10 --retry-max-time 60 "http://ci-files01-hki.intra.qt.io/input/semisecure/vncpw.txt" -o "$targetFile"
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
cat >"$HOME/Library/LaunchAgents/no-screensaver.plist" <<EOT
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
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -clientopts -setvnclegacy -vnclegacy yes -clientopts -setvncpw -vncpw $VNCPassword -restart -agent -privs -all
set -x

echo "Set Network Test Server address to $NTS_IP in /etc/hosts"
echo "$NTS_IP    qt-test-server qt-test-server.qt-test-net" | sudo tee -a /etc/hosts

sudo systemsetup settimezone GMT
sudo systemsetup setusingnetworktime off
sudo rm -f "$targetFile"
