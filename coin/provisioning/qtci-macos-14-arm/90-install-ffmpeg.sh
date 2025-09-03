#!/usr/bin/env bash
#Copyright (C) 2025 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

source "${BASH_SOURCE%/*}/../common/macos/install-ffmpeg-macos.sh" "macos-universal"
source "${BASH_SOURCE%/*}/../common/unix/install-ffmpeg-android.sh" "android-arm64" "use_16kb_page_size"
source "${BASH_SOURCE%/*}/../common/unix/install-ffmpeg-ios.sh"
