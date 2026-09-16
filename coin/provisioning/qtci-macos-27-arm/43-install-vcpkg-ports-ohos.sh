#!/bin/bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

brew install autoconf autoconf-archive automake libtool

# shellcheck source=../common/unix/install-vcpkg-ports-ohos.sh
source "${BASH_SOURCE%/*}/../common/unix/install-vcpkg-ports-ohos.sh"
