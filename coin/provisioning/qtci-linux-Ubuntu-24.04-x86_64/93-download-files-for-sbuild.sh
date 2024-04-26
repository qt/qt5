#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Get required deb files for sbuild to build qt debian packages for Ubuntu jammy
mkdir -p /home/qt/debian_packages
cd /home/qt/debian_packages || exit
# Backported cmake 3.24
wget https://ci-files01-hki.intra.qt.io/input/debian/cmake/amd64-jammy/cmake-3.24-deb.tar.gz
tar xzf cmake-3.24-deb.tar.gz
rm -rf cmake-3.24-deb.tar.gz
# TODO: Adapt this from jammy to noble Ubuntu 24.04:
# get rest of ready made Ubuntu jammy arm debian packages
# so that sbuild can find those

#wget http://ci-files01-hki.ci.qt.io/input/debian/icu/amd64-jammy/libicu-56.1-qt_56.1-1_amd64.deb
#wget http://ci-files01-hki.ci.qt.io/input/debian/icu/amd64-jammy/libicu-56.1-qt-dev_56.1-1_amd64.deb
