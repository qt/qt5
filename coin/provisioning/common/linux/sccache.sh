#!/usr/bin/env bash
# Copyright (C) 2018 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

source "${BASH_SOURCE%/*}/../unix/sccache.sh"

targetVersion=v0.15.0
if [[ $(uname -m) == 'aarch64' ]]; then
  targetArch=aarch64-unknown-linux-musl
  sha256=3a6a3712b49da3d263bf2d30d702de4302793016019e800bfb81c0c69401d8f8
else
  targetArch=x86_64-unknown-linux-musl
  sha256=782d2b5dd7ae0a55ebe368ab258114d0928d019ac2d949ab85d5d02f3926709e
fi

installSccache "$targetArch" "$targetVersion" "$sha256"
