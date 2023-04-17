#!/usr/bin/env bash

set -ex

source "${BASH_SOURCE%/*}/../common/unix/install-ffmpeg.sh" "macos-universal"
source "${BASH_SOURCE%/*}/../common/unix/install-ffmpeg-android.sh" "android-arm64"
