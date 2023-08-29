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

# Get required deb files for sbuild to build qt debian packages for Ubuntu focal
mkdir -p /home/qt/debian_packages
cd /home/qt/debian_packages
# Backported cmake 3.24
wget https://ci-files01-hki.intra.qt.io/input/debian/cmake/arm64-focal/cmake-3.24-deb.tar.gz
tar xzf cmake-3.24-deb.tar.gz
# get rest of ready made Ubuntu focal arm debian packages
# so that sbuild can find those
# QtWebEngine dependencies
wget http://ci-files01-hki.ci.qt.io/input/debian/libuv1/arm64-focal/libuv1_1.43.0.tar.gz
tar -xzf libuv1_1.43.0.tar.gz
rm -rf libuv1_1.43.0.tar.gz
wget http://ci-files01-hki.ci.qt.io/input/debian/nghttp2/arm64-focal/nghttp2_1.43.0.tar.gz
tar -xzf nghttp2_1.43.0.tar.gz
rm -rf nghttp2_1.43.0.tar.gz
wget http://ci-files01-hki.ci.qt.io/input/debian/nodejs/arm64-focal/nodejs_12.22.9.tar.gz
tar -xzf nodejs_12.22.9.tar.gz
rm -rf nodejs_12.22.9.tar.gz
# get ICU
wget http://ci-files01-hki.ci.qt.io/input/debian/icu/arm64-focal/libicu-56.1-qt_56.1-1_arm64.deb
wget http://ci-files01-hki.ci.qt.io/input/debian/icu/arm64-focal/libicu-56.1-qt-dev_56.1-1_arm64.deb






