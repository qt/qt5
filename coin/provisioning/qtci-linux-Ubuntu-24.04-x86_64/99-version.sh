#!/bin/bash
#Copyright (C) 2023 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

BASEDIR=$(dirname "$0")
# shellcheck source=../common/linux/distro_version_check.sh
source "$BASEDIR/../common/linux/distro_version_check.sh"

# Check distro version if it has changed
verify_os_version_unchanged

BASEDIR=$(dirname "$0")
"$BASEDIR/../common/linux/ubuntu-version.sh"
