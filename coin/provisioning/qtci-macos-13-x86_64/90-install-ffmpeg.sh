#!/usr/bin/env bash
#Copyright (C) 2023 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

source "${BASH_SOURCE%/*}/../common/unix/install-ffmpeg.sh" "macos-universal"
source "${BASH_SOURCE%/*}/../common/unix/install-ffmpeg-android.sh" "android-arm64"
source "${BASH_SOURCE%/*}/../common/unix/install-ffmpeg-ios.sh"
