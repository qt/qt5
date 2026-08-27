#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"

set -ex

sudo dnf install -y 7zip-standalone-all

sudo ln -s /usr/bin/7zz /usr/bin/7z

