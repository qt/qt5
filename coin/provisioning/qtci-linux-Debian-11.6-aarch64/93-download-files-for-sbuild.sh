#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Get required deb files for sbuild to build qt debian packages for Ubuntu focal
mkdir -p /home/qt/debian_packages
cd /home/qt/debian_packages || exit
# Backported cmake 3.24
wget https://ci-files01-hki.intra.qt.io/input/debian/cmake/arm64-jammy/cmake-3.24-deb.tar.gz
tar xzf cmake-3.24-deb.tar.gz
# get rest of ready made Ubuntu arm debian packages
# so that sbuild can find those

wget http://ci-files01-hki.ci.qt.io/input/debian/icu/arm64-jammy/libicu-56.1-qt_56.1-1_arm64.deb
wget http://ci-files01-hki.ci.qt.io/input/debian/icu/arm64-jammy/libicu-56.1-qt-dev_56.1-1_arm64.deb






