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

# Install required packages with APT

set -ex

echo "Disabling auto update"
sudo sed -i 's/APT::Periodic::Update-Package-Lists "1";/APT::Periodic::Update-Package-Lists "0";/' /etc/apt/apt.conf.d/10periodic
for service in apt-daily.timer apt-daily-upgrade.timer apt-daily.service apt-daily-upgrade.service; do
    sudo systemctl stop $service
    sudo systemctl disable $service
done

# aptdaemon is used by update notifiers and similar and there is no point in having those (the symptom is aptd holding a lock)
for i in `seq 10`; do
    echo attempting to remove aptdaemon
    sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y remove aptdaemon || true
    # check that aptdaemon is no longer installed
    which aptd > /dev/null || break
    if [[ $i -eq 10 ]]; then
        exit 1
    fi
    sleep 10
done

# Git is not needed by builds themselves, but is nice to have
# immediately as one starts debugging
installPackages+=(git)
# 7zip is a needed decompressing tool
installPackages+=(p7zip-full)
# To be able to mount yocto-cache during builds
installPackages+=(nfs-common)
# libssl-dev provides headers for OpenSSL
installPackages+=(libssl-dev)
# Needed libraries for X11 support accordingly to https://wiki.qt.io/Building_Qt_5_from_Git
installPackages+=("^libxcb.*")
installPackages+=(libxkbcommon-dev)
installPackages+=(libxkbcommon-x11-dev)
installPackages+=(libx11-xcb-dev)
installPackages+=(libglu1-mesa-dev)
installPackages+=(libxrender-dev)
installPackages+=(libxi-dev)
# Enable linking to system dbus
installPackages+=(libdbus-1-dev)
# Needed libraries for WebEngine
installPackages+=(libudev-dev)
installPackages+=(libegl1-mesa-dev)
installPackages+=(libfontconfig1-dev)
installPackages+=(libxss-dev)
# Common event loop handling
installPackages+=(libglib2.0-dev)
# MySQL support
installPackages+=(libmysqlclient-dev)
# PostgreSQL support
installPackages+=(libpq-dev)
# SQLite support
installPackages+=(libsqlite3-dev)
# ODBC support
installPackages+=(unixodbc-dev)
# Support for FreeType font engine
installPackages+=(libfreetype6-dev)
# Enable the usage of system jpeg libraries
installPackages+=(libjpeg-dev)
# Enable support for printer driver
installPackages+=(libcups2-dev)
# Install libraries needed for QtMultimedia to be able to support all plugins
installPackages+=(libasound2-dev)
installPackages+=(libgstreamer1.0-dev)
installPackages+=(libgstreamer-plugins-base1.0-dev)
installPackages+=(libgstreamer-plugins-good1.0-dev)
installPackages+=(libgstreamer-plugins-bad1.0-dev)
# Support for cross-building to x86 (needed by WebEngine boot2qt builds)
installPackages+=(g++-multilib)
# python2 development package
installPackages+=(python-pip)
# python3 development package
installPackages+=(python3-dev)
installPackages+=(python3-pip)
installPackages+=(python3-virtualenv)
# Needed to be able to build Yocto
installPackages+=(chrpath)
installPackages+=(gawk)
installPackages+=(texinfo)
# Automates interactive applications (Needed by RTA to automate configure testing)
installPackages+=(expect)
installPackages+=(mesa-common-dev)
installPackages+=(libgl1-mesa-glx)
installPackages+=(libgl1-mesa-dev)
installPackages+=(libegl1-mesa-dev)
installPackages+=(curl)
installPackages+=(libicu-dev)
installPackages+=(zlib1g-dev)
installPackages+=(zlib1g)
installPackages+=(zlib1g:i386)
installPackages+=(openjdk-8-jdk)
installPackages+=(libgtk-3-dev)
installPackages+=(ninja-build)
installPackages+=(libssl-dev)
installPackages+=(libxcursor-dev)
installPackages+=(libxcomposite-dev)
installPackages+=(libxdamage-dev)
installPackages+=(libxrandr-dev)
installPackages+=(libfontconfig1-dev)
installPackages+=(libxss-dev)
installPackages+=(libsrtp0-dev)
installPackages+=(libwebp-dev)
installPackages+=(libjsoncpp-dev)
installPackages+=(libopus-dev)
installPackages+=(libminizip-dev)
installPackages+=(libavutil-dev)
installPackages+=(libavformat-dev)
installPackages+=(libavcodec-dev)
installPackages+=(libevent-dev)
installPackages+=(bison)
installPackages+=(flex)
installPackages+=(gperf)
installPackages+=(libasound2-dev)
installPackages+=(libpulse-dev)
installPackages+=(libxtst-dev)
installPackages+=(libnspr4-dev)
installPackages+=(libnss3-dev)
installPackages+=(libopenal-dev)
installPackages+=(libbluetooth-dev)
#VirtualBox for RTA
installPackages+=(virtualbox)
installPackages+=(dkms)

echo "Running update for apt"
sudo apt-get update
echo "Installing packages"
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install "${installPackages[@]}"

sudo tee "/etc/apt/sources.list" > /dev/null <<-EOC
deb [arch=amd64] http://repo-clones.ci.qt.io/apt-mirror/mirror/ubuntu.trumpetti.atm.tut.fi/ubuntu/ xenial main restricted universe multiverse
deb [arch=amd64] http://repo-clones.ci.qt.io/apt-mirror/mirror/ubuntu.trumpetti.atm.tut.fi/ubuntu/ xenial-updates main restricted universe multiverse
deb [arch=amd64] http://repo-clones.ci.qt.io/apt-mirror/mirror/ubuntu.trumpetti.atm.tut.fi/ubuntu/ xenial-backports main restricted universe
deb [arch=amd64] http://repo-clones.ci.qt.io/apt-mirror/mirror/ubuntu.trumpetti.atm.tut.fi/ubuntu/ xenial-security main restricted universe multiverse
EOC
