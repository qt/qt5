#!/usr/bin/env bash
#Copyright (C) 2023 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Requires iptables-persistent apt package

sudo mkdir /etc/iptables
sudo bash -c "iptables-save > /etc/iptables/rules.v4"
