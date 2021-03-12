#!/usr/bin/env bash

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
echo "Setting up workaround for Ubuntu systemd resolve bug"
sudo rm -f /etc/resolv.conf
sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

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
