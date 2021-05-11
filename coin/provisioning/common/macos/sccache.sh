#!/usr/bin/env bash
# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

source "${BASH_SOURCE%/*}/../unix/sccache.sh"

targetVersion=v0.11.0
if [[ `arch` == arm* ]]; then
    targetArch=aarch64-apple-darwin
    sha1=3261ab99e5bb1f9f36eafa597d11491bd85da5ec
else
    targetArch=x86_64-apple-darwin
    sha1=57810789bf2813dfa9bf5da26a712dc30b56ce16
fi
installSccache "$targetArch" "$targetVersion" "$sha1"
