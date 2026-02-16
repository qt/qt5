#!/bin/sh
# Copyright (C) 2024 The Qt Company Ltd
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

sudo mkdir -p /etc/wicked/scripts
echo "ethtool -K \$2 tso off" | sudo tee -a /etc/wicked/scripts/net_tso_off
sudo chmod 744 /etc/wicked/scripts/net_tso_off
echo "PRE_UP_SCRIPT='wicked:/etc/wicked/scripts/net_tso_off'" | sudo tee -a /etc/sysconfig/network/ifcfg-eth0
