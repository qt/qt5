#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# load dummy sound module
sudo modprobe snd-dummy

# Check result
if lsmod | grep -q snd_dummy
then
    echo "(**) Dummy sound driver loaded.";
else
    echo "(EE) Failed to load dummy sound driver.";
    exit 1;
fi
