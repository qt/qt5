#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2020 The Qt Company Ltd.
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

# Remove update notifications and packagekit running in the background
sudo yum -y remove PackageKit gnome-software

installPackages=()
installPackages+=(git)
installPackages+=(zlib-devel)
installPackages+=(glib2-devel)
installPackages+=(openssl-devel)
installPackages+=(freetype-devel)
installPackages+=(fontconfig-devel)
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
installPackages+=(gstreamer1-devel)
installPackages+=(gstreamer1-plugins-base-devel)
# gtk3 style for QtGui/QStyle
installPackages+=(gtk3-devel)
# libusb1 for tqtc-boot2qt/qdb
installPackages+=(libusbx-devel)
# speech-dispatcher-devel for QtSpeech, otherwise it has no backend on Linux
installPackages+=(speech-dispatcher-devel)
# Python 2 devel and pip. python-pip requires the EPEL repository to be added
installPackages+=(python-devel python-pip)
# Python 3 with python-devel, pip and virtualenv
installPackages+=(rh-python36)
installPackages+=(python36-devel)
# WebEngine
installPackages+=(bison)
installPackages+=(flex)
installPackages+=(gperf)
installPackages+=(alsa-lib-devel)
installPackages+=(pulseaudio-libs-devel)
installPackages+=(libXtst-devel)
installPackages+=(nspr-devel)
installPackages+=(nss-devel)
installPackages+=(rh-nodejs12-nodejs)
installPackages+=(rh-nodejs12-nodejs-devel)
# For Android builds
installPackages+=(java-1.8.0-openjdk-devel)
# For receiving shasum
installPackages+=(perl-Digest-SHA)
# For Clang 11 tests
installPackages+=(perl-Digest-MD5)
# INTEGRITY requirements
installPackages+=(glibc.i686)
# Enable Qt Bluetooth
installPackages+=(bluez-libs-devel)
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
installPackages+=(xcb-util-devel)
installPackages+=(xcb-util-image-devel)
installPackages+=(xcb-util-keysyms-devel)
installPackages+=(xcb-util-wm-devel)
installPackages+=(xcb-util-renderutil-devel)
# ODBC support
installPackages+=(unixODBC-devel)
installPackages+=(unixODBC)
# Vulkan support
installPackages+=(vulkan-devel)
# Conan: For Python build
installPackages+=(xz-devel)
installPackages+=(zlib-devel)
installPackages+=(libffi-devel)
installPackages+=(libsqlite3x-devel)
# Build.pl
installPackages+=(perl-Data-Dumper)

sudo yum -y install "${installPackages[@]}"

sudo ln -s /opt/rh/rh-python36/root/usr/bin/python3 /usr/local/bin/python3
sudo ln -s /opt/rh/rh-python36/root/usr/bin/pip3 /usr/local/bin/pip3
# We shouldn't use yum to install virtualenv. The one found from package repo is not
# working, but we can use installed pip
sudo pip install --upgrade pip
sudo pip install virtualenv wheel

# Needed by packaging scripts
sudo /usr/local/bin/pip3 install colorlog --user

sudo /usr/local/bin/pip3 install wheel
# Install all needed packages in a special wheel cache directory
/usr/local/bin/pip3 wheel --wheel-dir "$HOME/python3-wheels" -r "${BASH_SOURCE%/*}/../common/shared/requirements.txt"

# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"
SetEnvVar "PYTHON3_WHEEL_CACHE" "$HOME/python3-wheels"
