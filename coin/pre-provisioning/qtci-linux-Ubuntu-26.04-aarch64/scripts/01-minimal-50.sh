#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -euo pipefail

# This script is run on the minimal -50 image
# Other scripts will be run on the -50 -> -51 cloned image

readonly CI_USER="${CI_USER:-qt}"
export DEBIAN_FRONTEND=noninteractive

# Debian/Ubuntu implementation. Replace this script with the distro's package
# manager commands when reusing the generic wrapper and HCL elsewhere.
apt-get update
apt-get -y full-upgrade
apt-get install -y qemu-guest-agent
systemctl enable qemu-guest-agent

dpkg-query -W -f='${binary:Package}\t${Version}\n' \
  > /var/tmp/qtci-minimal-image-packages.txt

apt-get -y autoremove
apt-get clean
rm -rf /var/lib/apt/lists/*

qemu-ga --version
