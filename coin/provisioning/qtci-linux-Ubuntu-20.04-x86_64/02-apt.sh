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
sudo sed -i 's/APT::Periodic::Update-Package-Lists "1";/APT::Periodic::Update-Package-Lists "0";/' /etc/apt/apt.conf.d/10periodic
for service in apt-daily.timer apt-daily-upgrade.timer apt-daily.service apt-daily-upgrade.service; do
    sudo systemctl stop $service
    sudo systemctl disable $service
done

function set_internal_repo {

    # Stop fetching the dep-11 metadata, since our mirrors do not handle them well
    sudo mv /etc/apt/apt.conf.d/50appstream{,.disabled}

    sudo tee "/etc/apt/sources.list" > /dev/null <<-EOC
    deb [arch=amd64] http://repo-clones.ci.qt.io/apt-mirror/mirror/ubuntu/ focal main restricted universe multiverse
    deb [arch=amd64] http://repo-clones.ci.qt.io/apt-mirror/mirror/ubuntu/ focal-updates main restricted universe multiverse
    deb [arch=amd64] http://repo-clones.ci.qt.io/apt-mirror/mirror/ubuntu/ focal-backports main restricted universe
    deb [arch=amd64] http://repo-clones.ci.qt.io/apt-mirror/mirror/ubuntu/ focal-security main restricted universe multiverse
    deb [arch=i386] http://repo-clones.ci.qt.io/apt-mirror/mirror/ubuntu/ focal main restricted
    deb [arch=i386] http://repo-clones.ci.qt.io/apt-mirror/mirror/ubuntu/ focal-updates main restricted
    deb [arch=i386] http://repo-clones.ci.qt.io/apt-mirror/mirror/ubuntu/ focal universe
EOC
}

(ping -c 3 repo-clones.ci.qt.io && set_internal_repo) || echo "Internal package repository not found. Using public repositories."

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
installPackages+=(libudev-dev)
installPackages+=(libdrm-dev)
installPackages+=(libegl1-mesa-dev)
installPackages+=(libfontconfig1-dev)
installPackages+=(libgbm-dev)
installPackages+=(liblcms2-dev)
installPackages+=(libpci-dev)
installPackages+=(libre2-dev)
installPackages+=(libsnappy-dev)
installPackages+=(libva-dev)
installPackages+=(libvpx-dev)
installPackages+=(libxkbfile-dev)
installPackages+=(libxshmfence-dev)
installPackages+=(libxss-dev)
installPackages+=(nodejs-mozilla) # use nodejs-mozilla because nodejs is outdated
installPackages+=(python3-html5lib)

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
# Enable support for printer test
installPackages+=(cups-pdf)
# Install libraries needed for QtMultimedia to be able to support all plugins
installPackages+=(libasound2-dev)
installPackages+=(libgstreamer1.0-dev)
installPackages+=(libgstreamer-plugins-base1.0-dev)
installPackages+=(libgstreamer-plugins-good1.0-dev)
installPackages+=(libgstreamer-plugins-bad1.0-dev)
installPackages+=(libgstreamer-gl1.0-0)
installPackages+=(gir1.2-gst-plugins-base-1.0)
installPackages+=(gir1.2-gst-plugins-bad-1.0)
installPackages+=(yasm)
installPackages+=(libva-dev)
# for QtMultimedia streaming tests
installPackages+=(vlc-bin)
installPackages+=(vlc-plugin-base)

# Support for cross-building to x86 (needed by WebEngine boot2qt builds)
installPackages+=(g++-multilib)
# python3 development package
installPackages+=(python3-dev)
installPackages+=(python3-pip)
installPackages+=(virtualenv)
installPackages+=(python3-wheel)
# python2 development package
installPackages+=(python-dev)
# Automates interactive applications (Needed by RTA to automate configure testing)
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
installPackages+=(openjdk-8-jdk)
#Java 11 for Android
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
#VirtualBox for RTA
installPackages+=(virtualbox)
installPackages+=(dkms)
# Needed for qtspeech
installPackages+=(libspeechd-dev)
#Pypdf for PDF reading in RTA tests
installPackages+=(python-pypdf2)
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
# For remote access
installPackages+=(ssh)
# For bitbake
installPackages+=(diffstat)
installPackages+=(binfmt-support)
installPackages+=(zstd)
# Vulkan is needed for examples
installPackages+=(libvulkan-dev)
# Needed for qtdltlogging
installPackages+=(libdlt-dev)
# For integrity
installPackages+=(libc6:i386)
installPackages+=(libncurses5:i386)
installPackages+=(libstdc++6:i386)
installPackages+=(libx11-6:i386)
installPackages+=(lib32z1)
installPackages+=(linux-libc-dev:i386)
installPackages+=(libxcursor1:i386)
installPackages+=(libc6-dev-i386)
sudo dpkg --add-architecture i386
# For QNX
installPackages+=(nfs-kernel-server)
installPackages+=(net-tools)
installPackages+=(bridge-utils)

echo "Running update for apt"
waitLoop
sudo apt-get update
echo "Installing packages"
waitLoop
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install "${installPackages[@]}"

source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"
SetEnvVar "PATH" "/usr/lib/nodejs-mozilla/bin:\$PATH"

OpenSSLVersion="$(openssl version |cut -b 9-14)"
echo "OpenSSL = $OpenSSLVersion" >> ~/versions.txt

