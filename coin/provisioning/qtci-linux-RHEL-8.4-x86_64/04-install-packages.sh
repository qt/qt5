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

# Remove update notifications and packagekit running in the background
sudo yum -y remove PackageKit gnome-software

installPackages=()
installPackages+=(git)
installPackages+=(zlib-devel)
installPackages+=(glib2-devel)
installPackages+=(openssl3)
installPackages+=(openssl3-devel)
installPackages+=(freetype-devel)
installPackages+=(fontconfig-devel)
installPackages+=(curl-devel)
installPackages+=(expat-devel)
installPackages+=(gettext-devel)
installPackages+=(perl-devel)
installPackages+=(dh-autoreconf)
# cmake build
installPackages+=(ninja-build)
installPackages+=(pcre2-devel)
installPackages+=(double-conversion-devel)
installPackages+=(zstd)
# EGL support
installPackages+=(mesa-libEGL-devel)
installPackages+=(mesa-libGL-devel)
installPackages+=(libxkbfile-devel)
# Xinput2
installPackages+=(libXi-devel)
installPackages+=(mysql-server)
installPackages+=(mysql)
installPackages+=(mysql-devel)
installPackages+=(postgresql-devel)
installPackages+=(cups-devel)
installPackages+=(dbus-devel)
# gstreamer 1 for QtMultimedia
# Note! gstreamer1-plugins-bad-free needs to be upgraded or it will conflicts with gstreamer1-plugins-base-devel
installPackages+=(gstreamer1-plugins-bad-free)
installPackages+=(gstreamer1-devel)
installPackages+=(gstreamer1-plugins-base-devel)
# for QtMultimedia, ffmpeg
installPackages+=(yasm)
installPackages+=(libva-devel)
# gtk3 style for QtGui/QStyle
installPackages+=(gtk3-devel)
# libusb1 for tqtc-boot2qt/qdb
installPackages+=(libusbx-devel)
# speech-dispatcher-devel for QtSpeech, otherwise it has no backend on Linux
installPackages+=(speech-dispatcher-devel)
# Python 2 devel and pip. python-pip requires the EPEL repository to be added
installPackages+=(python2-devel python2-pip)
# Python 3 with python-devel, pip and virtualenv
installPackages+=(python36)
installPackages+=(python36-devel)
# Python 3.8 for pyside. Qt for Python support for Python 3.6 will be deprecated in within pyside6.3
installPackages+=(python38)
installPackages+=(python38-devel)
# WebEngine
installPackages+=(bison)
installPackages+=(flex)
installPackages+=(gperftools-libs)
installPackages+=(gperf)
installPackages+=(alsa-lib-devel)
installPackages+=(pulseaudio-libs-devel)
installPackages+=(libdrm-devel)
installPackages+=(libva-devel)
installPackages+=(libXtst-devel)
installPackages+=(libxshmfence-devel)
installPackages+=(nspr-devel)
installPackages+=(nss-devel)
installPackages+=(python3-html5lib)
installPackages+=(mesa-libgbm-devel)
# For Android builds
installPackages+=(java-11-openjdk-devel)
# For receiving shasum
installPackages+=(perl-Digest-SHA)
# INTEGRITY requirements
installPackages+=(glibc.i686)
# Enable Qt Bluetooth
installPackages+=(bluez-libs-devel)
# QtNfc
installPackages+=(pcsc-lite-devel)
# QtWebKit
installPackages+=(libxml2-devel)
installPackages+=(libxslt-devel)
# For building Wayland from source
installPackages+=(libffi-devel)
# QtWayland
installPackages+=(mesa-libwayland-egl)
installPackages+=(mesa-libwayland-egl-devel)
installPackages+=(libwayland-client)
installPackages+=(libwayland-cursor)
installPackages+=(libwayland-server)
# Jenkins
installPackages+=(chrpath)
# libxkbcommon
installPackages+=(libxkbcommon-devel)
installPackages+=(libxkbcommon-x11-devel)
# xcb-util-* libraries
installPackages+=(xcb-util)
installPackages+=(xcb-util-image-devel)
installPackages+=(xcb-util-keysyms-devel)
installPackages+=(xcb-util-wm-devel)
installPackages+=(xcb-util-renderutil-devel)
installPackages+=(xcb-util-cursor)
installPackages+=(xcb-util-cursor-devel)

# ODBC support
installPackages+=(unixODBC-devel)
installPackages+=(unixODBC)
# Vulkan support
installPackages+=(vulkan-devel)
installPackages+=(vulkan-tools)
# Conan: For Python build
installPackages+=(xz-devel)
installPackages+=(zlib-devel)
installPackages+=(libffi-devel)
installPackages+=(libsqlite3x-devel)
# Build.pl
installPackages+=(perl-Data-Dumper)
# In RedHat these come with Devtoolset
installPackages+=(gcc)
installPackages+=(gcc-c++)
installPackages+=(make)
# Open source VMware Tools
installPackages+=(open-vm-tools)

sudo yum -y install "${installPackages[@]}"

sudo ln -s /usr/bin/python2 /usr/bin/python

sudo dnf -y module install nodejs:12

# We shouldn't use yum to install virtualenv. The one found from package repo is not
# working, but we can use installed pip
sudo pip3 install --upgrade pip
sudo pip3 install virtualenv wheel
# Just make sure we have virtualenv to run with python3.8 -m virtualenv
sudo python3.8 -m pip install virtualenv wheel

sudo /usr/bin/pip3 install wheel

OpenSSLVersion="$(openssl3 version |cut -b 9-14)"
echo "OpenSSL = $OpenSSLVersion" >> ~/versions.txt
