#!/bin/sh

#############################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
## Contact: https://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see https://www.qt.io/terms-conditions. For further
## information use the contact form at https://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 3 as published by the Free Software
## Foundation and appearing in the file LICENSE.LGPL3 included in the
## packaging of this file. Please review the following information to
## ensure the GNU Lesser General Public License version 3 requirements
## will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 2.0 or (at your option) the GNU General
## Public license version 3 or any later version approved by the KDE Free
## Qt Foundation. The licenses are as published by the Free Software
## Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
## included in the packaging of this file. Please review the following
## information to ensure the GNU General Public License requirements will
## be met: https://www.gnu.org/licenses/gpl-2.0.html and
## https://www.gnu.org/licenses/gpl-3.0.html.
##
## $QT_END_LICENSE$
##
#############################################################################


# Increase the soft and hard RLIMIT_NOFILE and RLIMIT_NPROC limits.
# By default they are 256/unlimited and 709/1064
# and they sometimes create problems to the build process and telegraf.


set -e

PROVISIONING_DIR="$(dirname "$0")/../../"
. "$PROVISIONING_DIR"/common/unix/common.sourced.sh


echo "Current limits are:"
ulimit -a
launchctl limit

$CMD_INSTALL -m 644 -o root -g wheel  \
    $PROVISIONING_DIR/common/macos/limit.maxfiles.plist  \
    $PROVISIONING_DIR/common/macos/limit.maxproc.plist   \
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
