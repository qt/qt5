#!/usr/bin/env bash

# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

sudo yum -y install gcc-toolset-10 gcc-toolset-10-libatomic-devel

echo "source /opt/rh/gcc-toolset-10/enable" >> ~/.bashrc
