#!/bin/bash

#############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
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

# This script modified system settings for automated use

# shellcheck source=../common/try_catch.sh
source "${BASH_SOURCE%/*}/../common/try_catch.sh"

VNCPassword=qt
NTS_IP=10.212.2.216

ExceptionDisableScreensaver=100
ExceptionSetInitialDelay=101
ExceptionSetDelay=102
ExceptionVNC=103
ExceptionNTS=104
ExceptionDisableScreensaverPassword=105

try
(
    echo "Disable Screensaver"
    mkdir -p "$HOME/Library/LaunchAgents" || throw $ExceptionDisableScreensaver
    (
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
    ) || throw $ExceptionDisableScreensaver

    defaults write com.apple.screensaver askForPassword -int 0 || throw $ExceptionDisableScreensaverPassword

    echo "Set keyboard type rates and delays"
    # normal minimum is 15 (225 ms)
    defaults write -g InitialKeyRepeat -int 15 || throw $ExceptionSetInitialDelay
    # normal minimum is 2 (30 ms)
    defaults write -g KeyRepeat -int 2 || throw $ExceptionSetDelay

    echo "Enable remote desktop sharing"
    sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -clientopts -setvnclegacy -vnclegacy yes -clientopts -setvncpw -vncpw $VNCPassword -restart -agent -privs -all || throw $ExceptionVNC

    echo "Set Network Test Server address to $NTS_IP in /etc/hosts"
    echo "$NTS_IP    qt-test-server qt-test-server.qt-test-net" | sudo tee -a /etc/hosts || throw $ExceptionNTS

)
catch || {
    case $ex_code in
        $ExceptionDisableScreensaver)
            echo "Failed to disable screensaver."
            exit 1;
        ;;
        $ExceptionSetInitialDelay)
            echo "Failed to set initial delay of keyboard."
            exit 1;
        ;;
        $ExceptionSetDelay)
            echo "Failed to set delay of keyboard."
            exit 1;
        ;;
        $ExceptionVNC)
            echo "Failed to enable VNC."
            exit 1;
        ;;
        $ExceptionNTS)
            echo "Failed to set NTS."
            exit 1;
        ;;
        $ExceptionDisableScreensaverPassword)
            echo "Failed to disable requiring of password after screensaver is enabled."
            exit 1;
        ;;
    esac
}

