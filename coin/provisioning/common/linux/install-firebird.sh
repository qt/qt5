#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -e

SSL_VER=$1
PACK_TYPE=$2
PROVISIONING_DIR="$(dirname "$0")/../../"
# shellcheck source=../unix/common.sourced.sh
source "${BASH_SOURCE%/*}/../unix/common.sourced.sh"
# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"


localRepo=http://ci-files01-hki.ci.qt.io/input/docker
upstreamRepo=https://github.com/FirebirdSQL/firebird/releases/download/v5.0.0
packageFile=Firebird-5.0.0.1306-0-linux-x64.tar.gz
sha=9a04b54d308ca10394d5339fe039b9e367b441c2

DownloadURL  $localRepo/$packageFile $upstreamRepo/$packageFile $sha /tmp/$packageFile

tar xf /tmp/$packageFile -C /tmp
/tmp/Firebird-5.0.0.1306-0-linux-x64/install.sh -silent
