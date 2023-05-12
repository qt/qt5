#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

BASEDIR=$(dirname "$0")
# shellcheck source=../common/shared/network_test_server_ip.txt
source "$BASEDIR/../common/shared/network_test_server_ip.txt"

echo "Set Network Test Server address to $network_test_server_ip in /etc/hosts"
echo "$network_test_server_ip    qt-test-server qt-test-server.qt-test-net" | sudo tee -a /etc/hosts
echo "Set DISPLAY"
echo 'export DISPLAY=":0"' >> ~/.bashrc
# for current session
export DISPLAY=:0

# Set timezone to UTC.
sudo timedatectl set-timezone Etc/UTC
# disable Automatic screen lock
gsettings set org.gnome.desktop.screensaver lock-enabled false
# disable blank screen power saving
gsettings set org.gnome.desktop.session idle-delay 0

# Set Wayland enable as false.
echo "Setting Wayland enable as false"
sudo sed -i 's/#WaylandEnable=false/WaylandEnable=false/g' /etc/gdm/custom.conf

# Set system locale
sudo localectl set-locale LANG=en_US.UTF-8
