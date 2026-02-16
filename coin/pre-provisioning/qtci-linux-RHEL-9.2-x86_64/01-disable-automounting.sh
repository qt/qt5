#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

sudo tee -a /etc/dconf/db/local.d/00-media-automount <<"EOF"
[org/gnome/desktop/media-handling]
automount=false
automount-open=false
EOF

sudo dconf update

