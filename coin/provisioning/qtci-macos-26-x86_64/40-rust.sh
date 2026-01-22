#!/usr/bin/env bash
#Copyright (C) 2026 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

BASEDIR=$(dirname "$0")
source "$BASEDIR/../common/unix/install-rust.sh"

installPrefix="/opt/rust"

buildFolder="$HOME/rust_build"
# we need to build rust ourselves as no release binaries come with multiple targets
target="x86_64-apple-darwin,aarch64-apple-darwin"
# building as pretend nightly because Chromium uses nightly features by default
channel="nightly"

InstallRust $buildFolder $installPrefix $target $channel "4e4c946e54b3685f9c17e29c7e4dbb19217d5f2150fd0c774df886715be7d8e0"
