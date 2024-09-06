#!/usr/bin/env bash
# Copyright (C) 2018 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

source "${BASH_SOURCE%/*}/../unix/sccache.sh"

targetVersion=0.2.14

if [[ $(uname -m) == 'aarch64' ]]; then
  targetArch=aarch64-unknown-linux-musl
  sha1=0f9b57c423d77f7aa89bb642864ac7689d84d6a0
else
  targetArch=x86_64-unknown-linux-musl
  sha1=281680c0fc2c09173e94d12ba45d9f1b8e62e5b3
fi

installSccache "$targetArch" "$targetVersion" "$sha1"
