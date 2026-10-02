#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"

sudo snap install --classic rustup

version="1.92.0"

sudo mkdir /opt/rustup
sudo chmod o+w /opt/rustup
export RUSTUP_HOME=/opt/rustup
SetEnvVar "RUSTUP_HOME" "/opt/rustup"

rustup default $version

# Linux targets
rustup target add aarch64-unknown-linux-gnu
rustup target add x86_64-unknown-linux-gnu
rustup target add armv7-unknown-linux-gnueabihf

# Android targets
rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi
rustup target add i686-linux-android
rustup target add x86_64-linux-android

export CARGO_HOME=/opt/rustup
SetEnvVar "CARGO_HOME" "/opt/rustup"

export PATH=/opt/rustup/bin:$PATH
SetEnvVar "PATH" "/opt/rustup/bin:$PATH"

cargo install bindgen-cli
sudo chmod o-w /opt/rustup

echo "Rust = $version" >> ~/versions.txt
