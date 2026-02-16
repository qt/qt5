#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

"$(dirname "$0")/../common/unix/install-openssl.sh" "linux"
