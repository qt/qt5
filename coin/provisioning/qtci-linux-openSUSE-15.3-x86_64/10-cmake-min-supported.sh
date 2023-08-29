#!/usr/bin/env bash
#Copyright (C) 2023 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

"$(dirname "$0")/../common/linux/cmake_min_supported.sh"

# For testing Qt's CMake deployment API with CMake < 3.21, we need patchelf.
sudo zypper -nq install patchelf
