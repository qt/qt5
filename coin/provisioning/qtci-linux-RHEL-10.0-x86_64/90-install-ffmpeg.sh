#!/usr/bin/env bash

source "${BASH_SOURCE%/*}/../common/linux/install-ffmpeg-linux.sh"
source "${BASH_SOURCE%/*}/../common/unix/install-ffmpeg-android-multi-ndk.sh" --abi "x86_64" --page-size "16kb"
source "${BASH_SOURCE%/*}/../common/unix/install-ffmpeg-android-multi-ndk.sh" --abi "x86" --page-size "4kb"
