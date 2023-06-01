#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=./../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"

# This script will install Nodejs

version="18.16.0"
urlCache="http://ci-files01-hki.ci.qt.io/input/nodejs/node-v$version.pkg"
urlOffcial="https://nodejs.org/dist/v$version/node-v$version.pkg"
sha256="156aa5b9580288fb0b3c6134eb8fac64e50745d78d33eebe9e29eb7ff87b8e1e"

DownloadURL $urlCache $urlOffcial $sha256 "/tmp/node-v$version.pkg"
sudo installer -pkg "/tmp/node-v$version.pkg" -target /

 echo "Nodejs = $version" >> ~/versions.txt

