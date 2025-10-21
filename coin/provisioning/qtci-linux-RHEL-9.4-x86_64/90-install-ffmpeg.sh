#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../common/linux/install-ffmpeg-linux.sh"
source "${BASH_SOURCE%/*}/../common/unix/install-ffmpeg-android.sh" "android-x86_64" "use_16kb_page_size"
source "${BASH_SOURCE%/*}/../common/unix/install-ffmpeg-android.sh" "android-x86" "use_4kb_page_size"
