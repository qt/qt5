#!/usr/bin/env sh
#Copyright (C) 2023 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# Util-linux is needed for libuuid which is needed during the license service build
# Path to util-linux folder is defined in 'src/libs/qlicenseservice/CMakeLists.txt'
brew install util-linux
