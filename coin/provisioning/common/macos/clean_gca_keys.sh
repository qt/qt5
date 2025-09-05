#!/bin/bash
# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Delete GCA plists and leases plist to force their regeneration after next reboot
# This avoids IPv6 link-local address collision that would happen with
# multiple VMs from same image.

sudo rm -rf /var/db/dhcpclient
