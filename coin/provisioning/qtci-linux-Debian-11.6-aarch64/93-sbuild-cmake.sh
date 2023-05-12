#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

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






