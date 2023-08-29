#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Get required deb files for sbuild to build qt debian packages for Ubuntu focal
mkdir -p /home/qt/debian_packages
cd /home/qt/debian_packages || exit
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






