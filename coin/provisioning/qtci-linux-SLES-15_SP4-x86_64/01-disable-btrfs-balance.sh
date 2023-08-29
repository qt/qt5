#!/usr/bin/env bash
#Copyright (C) 2023 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# Stops the balance job if one is running at the moment. This is a very expensive thing to run and causes major slow down.
sudo systemctl stop btrfs-balance.service

# This will disable btrfs balance job scheduling.
sudo sed -i 's/BTRFS_BALANCE_PERIOD="weekly"/BTRFS_BALANCE_PERIOD="none"/g' /etc/sysconfig/btrfsmaintenance
