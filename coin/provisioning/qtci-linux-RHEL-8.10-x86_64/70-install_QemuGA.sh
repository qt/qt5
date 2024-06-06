#!/usr/bin/env bash

# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs QEMU Guest Agent

set -ex

sudo yum -y install qemu-guest-agent
sudo systemctl start qemu-guest-agent
