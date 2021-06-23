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

BASEDIR=$(dirname "$0")
# shellcheck source=../common/shared/network_test_server_ip.txt
source "$BASEDIR/../common/shared/network_test_server_ip.txt"
# shellcheck source=../common/unix/check_and_set_proxy.sh
source "${BASH_SOURCE%/*}/../common/unix/check_and_set_proxy.sh"

echo "Set timezone to UTC."
sudo timedatectl set-timezone Etc/UTC
echo "Timeout for blanking the screen (0 = never)"
gsettings set org.gnome.desktop.session idle-delay 0
echo "Prevents screen lock when screesaver goes active."
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.lockdown disable-lock-screen 'true'

sudo sed -i 's|GRUB_TIMEOUT=8|GRUB_TIMEOUT=0|g' /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

echo "Set Network Test Server address to $network_test_server_ip in /etc/hosts"
echo "$network_test_server_ip    qt-test-server qt-test-server.qt-test-net" | sudo tee -a /etc/hosts
echo "Set DISPLAY"
echo 'export DISPLAY=":0"' >> ~/.bashrc

sudo systemctl stop packagekit
sudo systemctl disable packagekit
sudo systemctl mask packagekit
while sudo fuser /usr/lib/packagekitd >/dev/null 2>&1 ; do
    echo "Waiting for PackageKit to finish..."
    sleep 5
done
sudo zypper -nq remove gnome-software

# shellcheck disable=SC2031
if [ "$http_proxy" != "" ]; then
    sudo sed -i 's/PROXY_ENABLED=\"no\"/PROXY_ENABLED=\"yes\"/' /etc/sysconfig/proxy
    sudo sed -i "s|HTTP_PROXY=\".*\"|HTTP_PROXY=\"$proxy\"|" /etc/sysconfig/proxy
fi
