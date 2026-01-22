#!/usr/bin/env bash
#Copyright (C) 2026 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

BASEDIR=$(dirname "$0")
source "$BASEDIR/../common/unix/install-rust.sh"

installPrefix="/opt/rust"

buildFolder="$HOME/rust_build"
# we need to build rust ourselves as no release binaries come with multiple targets
target="aarch64-apple-darwin,x86_64-apple-darwin"
# building as pretend nightly because Chromium uses nightly features by default
channel="nightly"

InstallRust $buildFolder $installPrefix $target $channel "a14619cd8f3b714665012baa7a6e47243dfda66bee2377eb83170bd1e6c31af0"
