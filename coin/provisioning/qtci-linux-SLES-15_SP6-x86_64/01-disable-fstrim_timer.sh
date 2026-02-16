#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# This will disable fstrim. The fstrim.timer is scheduled to activate the fstrim.service
sudo systemctl stop fstrim.timer
sudo systemctl disable fstrim.timer
