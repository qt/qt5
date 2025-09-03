#!/usr/bin/env bash
#Copyright (C) 2023 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

source "${BASH_SOURCE%/*}/../common/linux/install-ffmpeg-linux.sh"
source "${BASH_SOURCE%/*}/../common/unix/install-ffmpeg-android.sh" "android-x86_64" "use_16kb_page_size"
source "${BASH_SOURCE%/*}/../common/unix/install-ffmpeg-android.sh" "android-x86" "use_4kb_page_size"
