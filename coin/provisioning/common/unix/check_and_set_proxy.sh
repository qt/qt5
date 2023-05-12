#!/usr/bin/env bash
# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# shellcheck source=../shared/http_proxy.txt
source "${BASH_SOURCE%/*}/../shared/http_proxy.txt"

{ wget -q -e "http_proxy=$proxy" --spider proxy.intra.qt.io && echo "Setting http_proxy to $proxy" && export http_proxy=$proxy; } || echo "Proxy not detected at $proxy"
