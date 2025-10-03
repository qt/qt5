#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

curl -L https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -

# https://apt.llvm.org
# Ubuntu
# Noble (24.04) LTS

# 20
sudo apt-add-repository 'deb http://apt.llvm.org/noble/ llvm-toolchain-noble-20 main'

sudo apt update
sudo apt -y install clang-20 lldb-20 lld-20 libc++-20-dev
