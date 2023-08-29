#!/usr/bin/env bash
#Copyright (C) 2023 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# shellcheck source=../common/linux/gcc.sh
source "${BASH_SOURCE%/*}/../common/linux/gcc.sh"

InstallGCC 9.3.0 50 5038e8752407d14e5a70c8efc80c20a6d4219aaa 212f77d7b7fe1fdf01a1c0b0ebc9d82aeda5e1e0
