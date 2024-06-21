#!/usr/bin/env bash
# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

source "${BASH_SOURCE%/*}/../unix/sccache.sh"

targetVersion=0.2.14
if [[ `arch` == arm* ]]; then
    targetArch=aarch64-apple-darwin
    sha1=ad10cd4b8889fa08e193a4165ac664876a27c0dc
else
    targetArch=x86_64-apple-darwin
    sha1=764bc1664c0ff616d9980a6d127175d0a2041781
fi
installSccache "$targetArch" "$targetVersion" "$sha1"
