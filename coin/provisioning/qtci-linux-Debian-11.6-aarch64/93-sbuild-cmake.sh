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

# build cmake for the debian packgaes
# Create chroot for Ubuntu focal
#mk-sbuild --arch=amd64 --name=focal --debootstrap-mirror="http://archive.ubuntu.com/ubuntu/" --distro=ubuntu focal

mkdir -p /home/qt/debian_packages
cd /home/qt/debian_packages
wget https://ci-files01-hki.intra.qt.io/input/debian/cmake/amd64-focal/cmake-3.24-deb.tar.gz
tar xzf cmake-3.24-deb.tar.gz
#git clone git@gitlab.ics.com:qt6_packaging/tqtc/cmake.git
#wget https://github.com/Kitware/CMake/releases/download/v3.24.3/cmake-3.24.3.tar.gz -O cmake_3.24.3.orig.tar.gz
#dpkg-source -b cmake
#sbuild --build-dep-resolver=aptitude -sAd focal -c focal-amd64 cmake_3.24.3-1~bpo1.dsc






