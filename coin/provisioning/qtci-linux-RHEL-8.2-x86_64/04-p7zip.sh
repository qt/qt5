#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"

set -ex

name="p7zip"
version="7-11"
sudo dnf -y install "$name" "$name-plugins"

echo "$name = $version" >> ~/versions.txt
