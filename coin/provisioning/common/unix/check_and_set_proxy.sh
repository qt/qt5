#!/usr/bin/env bash
# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# shellcheck source=../shared/http_proxy.txt
source "${BASH_SOURCE%/*}/../shared/http_proxy.txt"

# check using wget, if not, check with curl.
if command -v wget > /dev/null; then
    if wget --quiet --execute "http_proxy=$proxy" --spider "proxy.intra.qt.io"; then
        echo "Setting http_proxy to $proxy"
        export http_proxy=$proxy
    else
        echo "Proxy not detected at $proxy"
    fi
elif command -v curl > /dev/null; then
    if curl --silent --proxy "$proxy" --head "proxy.intra.qt.io"; then
        echo "Setting http_proxy to $proxy"
        export http_proxy=$proxy
    else
        echo "Proxy not detected at $proxy"
    fi
else
    echo "Error: Neither 'wget' or 'curl' is installed. Cannot attempt to setup proxy."
    exit 1
fi
