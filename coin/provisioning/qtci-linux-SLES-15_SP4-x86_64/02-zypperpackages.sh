#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2022 The Qt Company Ltd.
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

set -ex

sudo zypper -nq install elfutils binutils

sudo zypper addrepo --no-gpgcheck https://download.opensuse.org/repositories/devel:gcc/SLE-15/devel:gcc.repo
sudo zypper refresh
sudo zypper -nq install --force-resolution gcc10 gcc10-c++

sudo /usr/sbin/update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 1 \
                                     --slave /usr/bin/g++ g++ /usr/bin/g++-10 \
                                     --slave /usr/bin/cc cc /usr/bin/gcc-10 \
                                     --slave /usr/bin/c++ c++ /usr/bin/g++-10

sudo zypper -nq install git ninja make patch wget tar

sudo zypper -nq install bison flex gperf \
        zlib-devel \
        libudev-devel \
        glib2-devel \
        libopenssl-3-devel \
        freetype2-devel \
        fontconfig-devel \
        sqlite3-devel \
        libxkbcommon-devel \
        libxkbcommon-x11-devel

sudo zypper -nq install cmake

sudo zypper -nq install p7zip

# EGL support
sudo zypper -nq install Mesa-libEGL-devel Mesa-libGL-devel

# ICU
sudo zypper -nq install libicu-devel libicu-suse65_1

# gtk3 style for QtGui/QStyle
sudo zypper -nq install gtk3-devel

# Xinput2
sudo zypper -nq install libXi-devel postgresql14 postgresql14-devel mysql-devel mysql mysql-server

# system provided XCB libraries
sudo zypper -nq install xcb-util-devel xcb-util-image-devel xcb-util-keysyms-devel \
         xcb-util-wm-devel xcb-util-renderutil-devel

# temporary solution for libxcb-cursor0 xcb-util-cursor-devel
sudo zypper addrepo --no-gpgcheck https://download.opensuse.org/repositories/home:liangqi_qt:branches:SUSE:SLE-15-SP4:GA/standard/home:liangqi_qt:branches:SUSE:SLE-15-SP4:GA.repo
sudo zypper refresh
sudo zypper -nq install --force-resolution libxcb-cursor0 xcb-util-cursor-devel

# qtwebengine
sudo zypper -nq install alsa-devel dbus-1-devel libxkbfile-devel libdrm-devel \
         libXcomposite-devel libXcursor-devel libXrandr-devel libXtst-devel \
         mozilla-nspr-devel mozilla-nss-devel glproto-devel libxshmfence-devel \
         libgbm-devel Mesa-dri-devel vulkan-devel

# qtwebengine, qtmultimedia+ffmpeg
sudo zypper -nq install libva-devel

# qtwebkit
sudo zypper -nq install libxml2-devel libxslt-devel

# yasm (for ffmpeg in multimedia)
sudo zypper -nq install yasm

# GStreamer (qtwebkit and qtmultimedia), pulseaudio (qtmultimedia)
sudo zypper -nq install gstreamer-devel gstreamer-plugins-base-devel libpulse-devel

# cups
sudo zypper -nq install cups-devel

# speech-dispatcher
sudo zypper -nq install libspeechd-devel
#sudo sed -i 's:includedir=/usr/include:includedir=/usr/include/speech-dispatcher:' /usr/lib64/pkgconfig/speech-dispatcher.pc

# ODBC support
sudo zypper -nq install unixODBC-devel unixODBC

# sqlite support
sudo zypper -nq install sqlite3 sqlite3-devel

# Java - needed by RTA jenkins
sudo zypper -nq install java

# open-vm-tools requires update. Version in tier1 is broken and causes segfault on boot.
sudo zypper -nq update open-vm-tools

# Tools to build Git
sudo zypper -nq install autoconf libcurl-devel libexpat-devel

# Nodejs - required by QtWebengine
sudo zypper -nq install nodejs16

# OpenSSL 3
sudo zypper -nq install openssl-3

gccVersion="$(gcc --version |grep gcc |cut -b 17-23)"
echo "GCC = $gccVersion" >> versions.txt
