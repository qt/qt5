#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2021 The Qt Company Ltd.
## Contact: https://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see https://www.qt.io/terms-conditions. For further
## information use the contact form at https://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 3 as published by the Free Software
## Foundation and appearing in the file LICENSE.LGPL3 included in the
## packaging of this file. Please review the following information to
## ensure the GNU Lesser General Public License version 3 requirements
## will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 2.0 or (at your option) the GNU General
## Public license version 3 or any later version approved by the KDE Free
## Qt Foundation. The licenses are as published by the Free Software
## Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
## included in the packaging of this file. Please review the following
## information to ensure the GNU General Public License requirements will
## be met: https://www.gnu.org/licenses/gpl-2.0.html and
## https://www.gnu.org/licenses/gpl-3.0.html.
##
## $QT_END_LICENSE$
##
#############################################################################

# Install required packages with APT

# shellcheck source=../common/linux/apt_wait_loop.sh
source "${BASH_SOURCE%/*}/../common/linux/apt_wait_loop.sh"

echo "Disabling auto update"
sudo tee "/etc/apt/apt.conf.d/20auto-upgrades" > /dev/null <<-EOC
    APT::Periodic::Update-Package-Lists "0";
    APT::Periodic::Unattended-Upgrade "1";
EOC

for service in apt-daily.timer apt-daily-upgrade.timer apt-daily.service apt-daily-upgrade.service; do
    sudo systemctl stop $service
    sudo systemctl disable $service
done


echo "Using public repositories for now. Repo-clones isn't set yet for Debian use"
# (ping -c 3 repo-clones.ci.qt.io && set_internal_repo) || echo "Internal package repository not found. Using public repositories."
echo "deb http://deb.debian.org/debian bullseye-backports main" | sudo tee -a /etc/apt/sources.list
echo "deb-src http://deb.debian.org/debian bullseye-backports main" | sudo tee -a /etc/apt/sources.list

# Make sure needed ca-certificates are available
sudo apt-get install --reinstall ca-certificates

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
installPackages+=(udev)
installPackages+=(libudev-dev)
installPackages+=(libegl1-mesa-dev)
installPackages+=(libfontconfig1-dev)
installPackages+=(libgbm-dev)
installPackages+=(libxkbfile-dev)
installPackages+=(libxshmfence-dev)
installPackages+=(libxss-dev)
# installPackages+=(nodejs) too old
installPackages+=(python3-html5lib)
#
## Common event loop handling
installPackages+=(libglib2.0-dev)
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
# Enable support for printer test
installPackages+=(cups-pdf)
# Install libraries needed for QtMultimedia to be able to support all plugins
installPackages+=(libasound2-dev)
installPackages+=(libgstreamer1.0-dev)
installPackages+=(libgstreamer-plugins-base1.0-dev)
installPackages+=(libgstreamer-plugins-bad1.0-dev)
installPackages+=(libgstreamer-gl1.0-0)
installPackages+=(gir1.2-gst-plugins-base-1.0)
installPackages+=(gir1.2-gst-plugins-bad-1.0)

## Support for cross-building to x86 (needed by WebEngine boot2qt builds)
#installPackages+=(g++-multilib)
## python3 development package
installPackages+=(python3-dev)
installPackages+=(python3-pip)
installPackages+=(python3-venv)
installPackages+=(virtualenv)
## Automates interactive applications (Needed by RTA to automate configure testing)
installPackages+=(expect)
installPackages+=(mesa-common-dev)
installPackages+=(libgl1-mesa-glx)
installPackages+=(libgl1-mesa-dev)
installPackages+=(libegl1-mesa-dev)
installPackages+=(libegl1)
installPackages+=(libegl-mesa0)
installPackages+=(libegl-dev)
installPackages+=(libglvnd-dev)
installPackages+=(libgles2-mesa-dev)
installPackages+=(curl)
installPackages+=(libcurl4-openssl-dev)
installPackages+=(libicu-dev)
installPackages+=(zlib1g-dev)
installPackages+=(zlib1g)
installPackages+=(openjdk-11-jdk)
installPackages+=(libgtk-3-dev)
installPackages+=(ninja-build)
installPackages+=(libssl-dev)
installPackages+=(libxcursor-dev)
installPackages+=(libxcomposite-dev)
installPackages+=(libxdamage-dev)
installPackages+=(libxrandr-dev)
installPackages+=(libfontconfig1-dev)
installPackages+=(libsrtp2-dev)
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
installPackages+=(libnss3)
installPackages+=(libopenal-dev)
installPackages+=(libbluetooth-dev)
installPackages+=(dkms)
# Needed for qtspeech
installPackages+=(libspeechd-dev)
#Pypdf for PDF reading in RTA tests
installPackages+=(python3-pypdf2)
# Needed for b2qt
installPackages+=(git-lfs)
installPackages+=(chrpath)
installPackages+=(gawk)
installPackages+=(texinfo)
# Needed for Poppler test in QtWebEngine
installPackages+=(libpoppler-cpp-dev)
# Needed for QtCore
installPackages+=(libdouble-conversion-dev)
installPackages+=(libpcre2-dev)
# Needed for qtgampepad
installPackages+=(libsdl2-2.0)
installPackages+=(libsdl2-dev)
# Needed for qtwebkit
installPackages+=(ruby)
installPackages+=(libxslt1-dev)
installPackages+=(libxml2-dev)
installPackages+=(libhyphen-dev)
## For remote access
installPackages+=(ssh)
## For bitbake
installPackages+=(diffstat)
installPackages+=(binfmt-support)
installPackages+=(zstd)
# Vulkan is needed for examples
installPackages+=(libvulkan-dev)
# Needed for qtdltlogging
installPackages+=(libdlt-dev)
# For QNX
installPackages+=(nfs-kernel-server)
installPackages+=(net-tools)
installPackages+=(bridge-utils)
## For debian building debian packages
installPackages+=(sbuild)
installPackages+=(ubuntu-dev-tools)
installPackages+=(apt-cacher-ng)
installPackages+=(devscripts)
installPackages+=(piuparts)
installPackages+=(ubuntu-dev-tools)
installPackages+=(libcurl4-openssl-dev)
installPackages+=(libexpat1-dev)
installPackages+=(libjsoncpp-dev)
installPackages+=(zlib1g-dev)
installPackages+=(libarchive-dev)
installPackages+=(libncurses5-dev)
installPackages+=(librhash-dev)
installPackages+=(libuv1-dev)
installPackages+=(python3-sphinx:native)
installPackages+=(dh-elpa)
installPackages+=(dh-sequence-sphinxdoc)
installPackages+=(debhelper-compat)
installPackages+=(default-libmysqlclient-dev)
installPackages+=(dh-exec)
installPackages+=(libcups2-dev)
installPackages+=(libdbus-1-dev)
installPackages+=(libegl-dev)
installPackages+=(libfontconfig-dev)
installPackages+=(libfreetype-dev)
installPackages+=(libgl-dev)
installPackages+=(libglib2.0-dev)
installPackages+=(libglx-dev)
installPackages+=(libgss-dev)
installPackages+=(libgtk-3-dev)
installPackages+=(libicu-dev)
installPackages+=(libpq-dev)
installPackages+=(libsqlite3-dev)
installPackages+=(libssl-dev)
installPackages+=(libvulkan-dev)
installPackages+=(libx11-dev)
installPackages+=(libx11-xcb-dev)
installPackages+=(libxcb-glx0-dev)
installPackages+=(libxcb-icccm4-dev)
installPackages+=(libxcb-image0-dev)
installPackages+=(libxcb-keysyms1-dev)
installPackages+=(libxcb-randr0-dev)
installPackages+=(libxcb-render-util0-dev)
installPackages+=(libxcb-render0-dev)
installPackages+=(libxcb-shape0-dev)
installPackages+=(libxcb-shm0-dev)
installPackages+=(libxcb-sync-dev)
installPackages+=(libxcb-util-dev)
installPackages+=(libxcb-xfixes0-dev)
installPackages+=(libxcb-xinerama0-dev)
installPackages+=(libxcb-xinput-dev)
installPackages+=(libxcb-xkb-dev)
installPackages+=(libxcb1-dev)
installPackages+=(libxext-dev)
installPackages+=(libxfixes-dev)
installPackages+=(libxi-dev)
installPackages+=(libxkbcommon-dev)
installPackages+=(libxkbcommon-x11-dev)
installPackages+=(libxrender-dev)
installPackages+=(ninja-build)
installPackages+=(pkg-config)
installPackages+=(pkg-kde-tools)
installPackages+=(unixodbc-dev)
installPackages+=(zlib1g-dev)
installPackages+=(libusb-1.0-0-dev)


echo "Running update for apt"
waitLoop
sudo apt-get update
echo "Installing packages"
waitLoop
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install "${installPackages[@]}"
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install cmake apt-cacher-ng -t bullseye-backports

# SetEnvVar "PATH" "/usr/lib/nodejs-mozilla/bin:\$PATH"

#OpenSSLVersion="$(openssl version |cut -b 9-14)"
#echo "OpenSSL = $OpenSSLVersion" >> ~/versions.txt

