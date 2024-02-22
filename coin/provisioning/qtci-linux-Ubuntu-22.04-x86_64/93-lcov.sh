#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Install lcov 2.0 from 24.04/noble numbat

echo "Installing lcov"
wget https://ci-files01-hki.ci.qt.io/input/lcov/lcov_2.0-4ubuntu1_all.deb
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y -o DPkg::Lock::Timeout=300 install -f ./lcov_2.0-4ubuntu1_all.deb
