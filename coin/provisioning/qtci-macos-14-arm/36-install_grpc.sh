#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# shellcheck source=../common/unix/install_grpc.sh
# Temporarily disabled due to OpenSSL linking errors
#source "${BASH_SOURCE%/*}/../common/unix/install_grpc.sh"

