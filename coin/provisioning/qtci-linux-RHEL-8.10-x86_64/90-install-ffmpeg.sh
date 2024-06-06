#!/usr/bin/env bash
#Copyright (C) 2023 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# TODO: investigate why the FFmpeg plugin can't find shared FFmpeg on rhel-8.8 / 8.10
source "${BASH_SOURCE%/*}/../common/unix/install-ffmpeg.sh" "linux" "static"
source "${BASH_SOURCE%/*}/../common/unix/install-ffmpeg-android.sh" "android-x86_64"
source "${BASH_SOURCE%/*}/../common/unix/install-ffmpeg-android.sh" "android-x86"
