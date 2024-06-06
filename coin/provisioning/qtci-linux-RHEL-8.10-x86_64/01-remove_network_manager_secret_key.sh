#!/usr/bin/env bash
#Copyright (C) 2023 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Ipv6 link local becomes tentative and dadfailed if two systems has the same secret_key
# New unique secret key will be created automatically during start up.
# https://access.redhat.com/solutions/3553581
echo "Removing secret_key"
sudo rm -f "/var/lib/NetworkManager/secret_key"


