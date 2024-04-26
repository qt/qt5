#!/usr/bin/env bash
# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script modifies system settings for automated use

set -ex

# shellcheck source=../common/unix/check_and_set_proxy.sh
source "${BASH_SOURCE%/*}/../common/unix/check_and_set_proxy.sh"

NTS_IP=10.212.2.216

echo "Set timezone to UTC."
sudo timedatectl set-timezone Etc/UTC
echo "Timeout for blanking the screen (0 = never)"
gsettings set org.gnome.desktop.session idle-delay 0
echo "Prevents screen lock when screesaver goes active."
gsettings set org.gnome.desktop.screensaver lock-enabled false
echo "Set grub timeout to 0"
sudo sed -i 's|GRUB_TIMEOUT=10|GRUB_TIMEOUT=0|g' /etc/default/grub
sudo update-grub

# https://bugs.launchpad.net/ubuntu/+source/systemd/+bug/1624320
# Checking if Ubuntu 20.04 works without this
#echo "Setting up workaround for Ubuntu systemd resolve bug"
#sudo rm -f /etc/resolv.conf
#sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

# remove hostname to get unique based on IP address
sudo rm /etc/hostname

echo "Set Network Test Server address to $NTS_IP in /etc/hosts"
echo "$NTS_IP    qt-test-server qt-test-server.qt-test-net" | sudo tee -a /etc/hosts

echo 'LC_ALL=en_US.UTF8' | sudo tee /etc/default/locale

if [ "$http_proxy" != "" ]; then
    echo "Acquire::http::Proxy \"$proxy\";" | sudo tee -a /etc/apt/apt.conf
fi

# This script diverts qtlogging.ini file so we don't get debugging related auto-test failures.
sudo dpkg-divert --divert /etc/xdg/QtProject/qtlogging.ini.foo --rename /etc/xdg/QtProject/qtlogging.ini
