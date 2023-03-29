#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# Make bootstap agent run in background without terminal view
# Terminal view can cause issues with Autotests

# Create shell wrapper to pass environment variables
wrapper="${HOME}/bootstrap-agent.sh"
autostart_folder="${HOME}/.config/autostart"
# This directory should exist. Created in base image (tier 1)
mkdir -p "${autostart_folder}"

# Create autostart desktop file and shell wrapper
sudo tee "${autostart_folder}/coin-bootstrap-agent.desktop" <<"EOF"
[Desktop Entry]
Type=Application
Exec=/home/qt/bootstrap-agent.sh
Hidden=false
X-GNOME-Autostart-enabled=true
Name=Coin
EOF

sudo tee "$wrapper" <<"EOF"
#!/bin/sh
# Wait for network to come up
x=0
while ! cat "/etc/resolv.conf" | grep -v "#" | grep "nameserver" > /dev/null ; do
    echo "(WW) wating for network ($x/20)..." >> /home/qt/bootstrap-agent.txt
    x=$((x+1))
    sleep 1
    if [ "$x" -gt 20 ]; then
        echo "(EE) netowrk down. Exiting bootstrap." >> /home/qt/bootstrap-agent.txt
        exit 1
    fi
done
echo "(**) network found." >>  /home/qt/bootstrap-agent.txt

# Wait for context to be mounted
x=0
while ! ([ -f "/media/qt/CONTEXT/context.sh" ] || [ -f "/media/CONTEXT/context.sh" ] || [ -f "/run/media/qt/CONTEXT/context.sh" ]); do
    echo "(WW) waiting for context file to be mounted ($x/20)..." >> /home/qt/bootstrap-agent.txt
    x=$((x+1))
    sleep 1
    if [ "$x" -gt 20 ]; then
        echo "(WW) no context file found. Mounting manually." >> /home/qt/bootstrap-agent.txt
        break
    fi
done

# establish mount path (differs per distro)
if ! ([ -f "/media/qt/CONTEXT/context.sh" ] || [ -f "/media/CONTEXT/context.sh" ] || [ -f "/run/media/qt/CONTEXT/context.sh" ]); then
    MOUNTPATH="invalid"
    if [ -d "/run/media/qt/CONTEXT" ]; then
            MOUNTPATH="/run/media/qt/CONTEXT"
    fi
    if [ -d "/media/qt/CONTEXT" ]; then
            MOUNTPATH="/media/qt/CONTEXT"
    fi
    if [ -d "/media/CONTEXT" ]; then
            MOUNTPATH="/media/CONTEXT"
    fi

    # try mounting if unmounted
    if [ -d "$MOUNTPATH" ]; then
        if ! mount | grep "$MOUNTPATH" > /dev/null ; then
            echo "(WW) context file not mounted..." >> /home/qt/bootstrap-agent.txt
            echo "(WW) waiting 1 minute" >> /home/qt/bootstrap-agent.txt
            sleep 60
            echo "(**) mount /dev/sr0 $MOUNTPATH" >> /home/qt/bootstrap-agent.txt
            sudo mount -r /dev/sr0 $MOUNTPATH
        fi
    fi
fi

if ([ -f "/media/qt/CONTEXT/context.sh" ] || [ -f "/media/CONTEXT/context.sh" ] || [ -f "/run/media/qt/CONTEXT/context.sh" ]); then
    echo "(**) context found." >>  /home/qt/bootstrap-agent.txt
else
    echo "(EE) context not found. Starting bootstrap anyway." >>  /home/qt/bootstrap-agent.txt
fi

/home/qt/bootstrap-agent /dev/ttyS0
EOF

# set owner and permissions
sudo chown qt:users "$wrapper"
sudo chmod 755 "$wrapper"
