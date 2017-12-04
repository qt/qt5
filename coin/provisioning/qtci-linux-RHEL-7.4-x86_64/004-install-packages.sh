#!/bin/bash

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

set -e

sudo yum -y update

sudo yum -y install git
sudo yum -y install zlib-devel
sudo yum -y install glib2-devel
sudo yum -y install openssl-devel
sudo yum -y install freetype-devel
sudo yum -y install fontconfig-devel

# EGL support
sudo yum -y install mesa-libEGL-devel
sudo yum -y install mesa-libGL-devel

sudo yum -y install libxkbfile-devel

# Xinput2
sudo yum -y install libXi-devel

sudo yum -y install python-devel
sudo yum -y install mysql-server mysql
sudo yum -y install mysql-devel
sudo yum -y install postgresql-devel
sudo yum -y install cups-devel
sudo yum -y install dbus-devel

# We have to downgrade to an older version of graphite2
# to avoid a dependency version mismatch with gtk3-devel package.

sudo yum -y downgrade graphite2-1.3.6-1.el7_2

# gstreamer 1 for QtMultimedia
sudo yum -y install gstreamer1-devel gstreamer1-plugins-base-devel

# gtk3 style for QtGui/QStyle
sudo yum -y install gtk3-devel

# libusb1 for tqtc-boot2qt/qdb
sudo yum -y install libusb-devel

# speech-dispatcher-devel for QtSpeech, otherwise it has no backend on Linux
sudo yum -y install speech-dispatcher-devel

# Python
sudo yum -y install python-devel python-virtualenv

# WebEngine
sudo yum -y install bison
sudo yum -y install flex
sudo yum -y install gperf
sudo yum -y install alsa-lib-devel
sudo yum -y install pulseaudio-libs-devel
sudo yum -y install libXtst-devel
sudo yum -y install nspr-devel
sudo yum -y install nss-devel

# For Android builds
sudo yum -y install java-1.8.0-openjdk-devel

# For receiving shasum
sudo yum -y install perl-Digest-SHA

# INTEGRITY requirements
sudo yum -y install glibc.i686

# Enable Qt Bluetooth
sudo yum -y install bluez-libs-devel
