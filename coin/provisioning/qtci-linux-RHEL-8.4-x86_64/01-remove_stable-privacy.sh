#!/usr/bin/env bash
# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
set -ex

echo "Change default stable-secret to based on MAC"
sudo sed -i '/^IPV6_ADDR_GEN_MODE/d' "/etc/sysconfig/network-scripts/ifcfg-ens192"
