#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/llvm.gpg > /dev/null

# https://apt.llvm.org
# Ubuntu
# resolute (26.04) LTS

# 21
echo 'deb [signed-by=/etc/apt/keyrings/llvm.gpg] http://apt.llvm.org/resolute/ llvm-toolchain-resolute-21 main' | sudo tee /etc/apt/sources.list.d/llvm.list > /dev/null

sudo apt update
sudo apt -y install clang-21 lldb-21 lld-21

# note: installing the libc++ development files conflicts with libgstreamer1.0-dev
# * installing libunwind-20-dev from apt.llvm.org (as dependency of libc++-20-dev) will
#   uninstall libgstreamer1.0-dev
# * installing libunwind-20-dev from the Ubuntu repository will break gstreamer's pkg-config
#   integration: https://bugs.launchpad.net/ubuntu/+source/llvm-toolchain-20/+bug/2134518
# sudo apt -y libc++-20-dev
