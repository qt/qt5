#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# Having proxy set while running autotests makes them fail
sudo sed -i 's/PROXY_ENABLED=\"yes\"/PROXY_ENABLED=\"no\"/' /etc/sysconfig/proxy

