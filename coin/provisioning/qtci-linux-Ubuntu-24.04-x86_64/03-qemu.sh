#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"

# First test using QFont fails if fonts-noto-cjk is installed. This happens because
# running fontcache for that font takes > 5 mins when run on QEMU. Running fc-cache
# doesn't help since host version creates cache for a wrong architecture and running
# armv7 fc-cache segfaults on QEMU.
sudo DEBIAN_FRONTEND=noninteractive apt-get -y remove fonts-noto-cjk

# Disable QtWayland window decorations, as they cause flakiness when used inside qemu (QTBUG-66173)
qemu_env="QT_WAYLAND_DISABLE_WINDOWDECORATION=1"

SetEnvVar "QEMU_SET_ENV" "\"${qemu_env}\""
