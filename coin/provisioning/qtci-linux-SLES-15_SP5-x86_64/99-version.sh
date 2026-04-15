#!/usr/bin/env bash
# Copyright (C) 2018 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script needs to be called last during provisioning so that the software information will show up last in provision log.

# Storage installed RPM packages information

set -ex

BASEDIR=$(dirname "$0")
# shellcheck source=../common/linux/distro_version_check.sh
source "$BASEDIR/../common/linux/distro_version_check.sh"

# Check distro version if it has changed
verify_os_version_unchanged

# shellcheck disable=SC2129
echo "*********************************************" >> ~/versions.txt
echo "***** All installed RPM packages *****" >> ~/versions.txt
rpm -q -a | sort >> ~/versions.txt
echo "*********************************************" >> ~/versions.txt

"$(dirname "$0")/../common/linux/version.sh"
