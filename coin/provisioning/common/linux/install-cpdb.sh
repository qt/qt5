#!/usr/bin/env bash

# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script install cpdb from sources.
# Requires GCC and Perl to be in PATH.
# The following dependencies should be pre-installed:
#  make, autoconf, autopoint, libglib2.0-dev, libdbus-1-dev, libtool
set -ex

repName="cpdb-libs"
gitUrl="https://github.com/openprinting/$repName.git"
tmpdir="/tmp"
repDir="$tmpdir/$repName"
prefix="/usr"
rm -rf $repDir
cd $tmpdir
git clone $gitUrl >/dev/null
cd $repDir
# cpdb-libs v2.0b4 with build bug fixed
git checkout ce848f1571a82ec03881fce127ff28bec8da239e > /dev/null
./autogen.sh > /dev/null
./configure --prefix=$prefix > /dev/null
make -j$(nproc) > /dev/null && sudo make install > /dev/null
sudo ldconfig
rm -rf $repDir
