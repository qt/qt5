#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# Disalbe updates
echo "Disabling auto-upgrades"
sudo sed -i 's/"1"/"0"/g' /etc/apt/apt.conf.d/20auto-upgrades
