#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Install lcov 2.4 from 26.04/resolute raccoon

echo "Installing lcov"
wget https://ci-files01-hki.ci.qt.io/input/lcov/lcov_2.4-3_all.deb
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y -o DPkg::Lock::Timeout=300 install -f ./lcov_2.4-3_all.deb
