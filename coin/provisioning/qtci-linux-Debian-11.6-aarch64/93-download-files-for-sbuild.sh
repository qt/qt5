#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Get required deb files for sbuild to build qt debian packages for Ubuntu focal
mkdir -p /home/qt/debian_packages
cd /home/qt/debian_packages || exit
# Minimum version cmake 3.25. Downloaded from
# wget https://apt.kitware.com//ubuntu/pool/main/c/cmake/cmake_3.25.1-0kitware1ubuntu22.04.1_arm64.deb
# wget https://apt.kitware.com//ubuntu/pool/main/c/cmake/cmake-data_3.25.1-0kitware1ubuntu22.04.1_all.deb

wget https://ci-files01-hki.ci.qt.io/input/debian/cmake/arm64-jammy/cmake_3.25.1-0kitware1ubuntu22.04.1_arm64.deb
wget https://ci-files01-hki.ci.qt.io/input/debian/cmake/arm64-jammy/cmake-data_3.25.1-0kitware1ubuntu22.04.1_all.deb
