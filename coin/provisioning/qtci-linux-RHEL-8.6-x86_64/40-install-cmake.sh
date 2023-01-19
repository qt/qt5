#!/usr/bin/env bash

# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs CMake 3.6.2

set -ex

# CMake is needed for autotests that verify that Qt can be built with CMake

# shellcheck source=../common/linux/cmake_linux.sh
source "${BASH_SOURCE%/*}/../common/linux/cmake_linux.sh"
