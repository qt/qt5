#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"

set -ex

name="p7zip"
version="7-11"
sudo yum -y install "$name"

# Link 7za to 7z so we can use existing installation scripts
sudo ln -s /usr/bin/7za /usr/bin/7z

echo "$name = $version" >> ~/versions.txt
