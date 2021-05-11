#!/usr/bin/env bash
# Copyright (C) 2018 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

source "${BASH_SOURCE%/*}/../unix/sccache.sh"

targetVersion=v0.11.0
if [[ $(uname -m) == 'aarch64' ]]; then
  targetArch=aarch64-unknown-linux-musl
  sha1=b7606d0fb461c0aa7351f511d9223416a322d52a
else
  targetArch=x86_64-unknown-linux-musl
  sha1=ef389a20c85b732cccd48436a5e28ed40bed2806
fi

installSccache "$targetArch" "$targetVersion" "$sha1"
