#!/bin/bash
# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only


# Increase the soft and hard RLIMIT_NOFILE and RLIMIT_NPROC limits.
# By default they are 256/unlimited and 709/1064
# and they sometimes create problems to the build process and telegraf.


set -e

PROVISIONING_DIR="$(dirname "$0")/../../"
# shellcheck source=../unix/common.sourced.sh
source "$PROVISIONING_DIR"/common/unix/common.sourced.sh

echo "Current limits are:"
ulimit -a
launchctl limit

$CMD_INSTALL -m 644 -o root -g wheel  \
    "$PROVISIONING_DIR/common/macos/limit.maxfiles.plist"  \
    "$PROVISIONING_DIR/common/macos/limit.maxproc.plist"   \
    /Library/LaunchDaemons/

# Activate the new limits immediately (not for the current session though)
sudo launchctl load -w /Library/LaunchDaemons/limit.maxfiles.plist
sudo launchctl load -w /Library/LaunchDaemons/limit.maxproc.plist

echo "After adjusting, limits are:"
ulimit -a
launchctl limit


# NOTE: If the limits are not increased enough, it might be because of
# restrictions set by the kernel. They can be temporarily altered with:

# sudo sysctl -w kern.maxproc=xxxx
# sudo sysctl -w kern.maxprocperuid=xxx
