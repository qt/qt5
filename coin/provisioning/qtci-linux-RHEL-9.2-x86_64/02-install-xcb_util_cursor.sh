#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# Install xcb-util-cursor* libraries before updating repos. In updated repos these libraries are no longer available.
# QTQAINFRA-6325
sudo yum -y install xcb-util-cursor
sudo yum -y install xcb-util-cursor-devel
