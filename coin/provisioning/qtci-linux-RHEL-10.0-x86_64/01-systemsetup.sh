#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

BASEDIR=$(dirname "$0")
# shellcheck source=../common/shared/network_test_server_ip.txt
source "$BASEDIR/../common/shared/network_test_server_ip.txt"
# shellcheck source=../common/linux/distro_version_check.sh
source "$BASEDIR/../common/linux/distro_version_check.sh"

# Get distro version to later check if version has changed at the end of the provisioning
record_os_version

echo "Set Network Test Server address to $network_test_server_ip in /etc/hosts"
echo "$network_test_server_ip    qt-test-server qt-test-server.qt-test-net" | sudo tee -a /etc/hosts

# Set timezone to UTC.
sudo timedatectl set-timezone Etc/UTC

"$BASEDIR/../common/linux/configure-gnome-shell.sh"

echo "Disable windows key from showing the GNOME Shell Activities overlay"
gsettings set org.gnome.mutter overlay-key ""
