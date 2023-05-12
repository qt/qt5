#!/usr/bin/env bash
# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

source "${BASH_SOURCE%/*}/../unix/sccache.sh"

targetArch=x86_64-apple-darwin
targetVersion=0.2.14
sha1=764bc1664c0ff616d9980a6d127175d0a2041781
installSccache "$targetArch" "$targetVersion" "$sha1"
