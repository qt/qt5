#!/usr/bin/env bash
# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

source "${BASH_SOURCE%/*}/../unix/sccache.sh"

targetVersion=v0.15.0
if [[ `arch` == arm* ]]; then
    targetArch=aarch64-apple-darwin
    sha256=430ef7b5f54256d3ed5bfe77e8b0afc51aa209aeebe4f95b69c3a52ce3acc6e9
else
    targetArch=x86_64-apple-darwin
    sha256=f8da93e0689122268f720ddb48c8357f3da18be8c88aff23a8e75a7a219367db
fi
installSccache "$targetArch" "$targetVersion" "$sha256"
