#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=./../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"

# This script will install Nodejs

version="22.21.1"
urlCache="http://ci-files01-hki.ci.qt.io/input/nodejs/node-v$version.pkg"
urlOffcial="https://nodejs.org/dist/v$version/node-v$version.pkg"
sha256="182ad62634eabbb11497c2284a3172771944f1cd17e23b143e778bd189af6d65"

DownloadURL $urlCache $urlOffcial $sha256 "/tmp/node-v$version.pkg"
sudo installer -pkg "/tmp/node-v$version.pkg" -target /

 echo "Nodejs = $version" >> ~/versions.txt

