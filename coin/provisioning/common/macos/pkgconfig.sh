#!/usr/bin/env bash
# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Install pkgconfig
set -ex

source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"
brew install pkgconfig
read -r -a arr <<< "$(brew list --versions pkgconfig)"
version=${arr[1]}
echo "pkgconfig = $version" >> ~/versions.txt
