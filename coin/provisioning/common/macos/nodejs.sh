#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=./../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"

# This script will install Nodejs

version="14.16.1"
urlCache="http://ci-files01-hki.intra.qt.io/input/nodejs/node-v$version.pkg"
urlOffcial="https://nodejs.org/dist/v$version/node-v$version.pkg"
sha1="4720274971c40fe51b2c647060f77c45fb4949a7"

DownloadURL $urlCache $urlOffcial $sha1 "/tmp/node-v$version.pkg"
sudo installer -pkg "/tmp/node-v$version.pkg" -target /

 echo "Nodejs = $version" >> ~/versions.txt

