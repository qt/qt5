#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script install cpdb from sources.
# Requires GCC and Perl to be in PATH.
set -ex

# Install the dependencies
sudo apt install -y make autoconf autopoint libglib2.0-dev libdbus-1-dev libtool

BASEDIR=$(dirname "$0")
"$BASEDIR/../common/linux/install-cpdb.sh"
