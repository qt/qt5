#!/usr/bin/env bash
#Copyright (C) 2026 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"
# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"

checksum="83051570e514a10b6f60d732cd2c35eb3fcc9d3d"
url="https://download.swift.org/swiftly/linux/swiftly-1.1.1-x86_64.tar.gz"
url_cached="http://ci-files01-hki.ci.qt.io/input/swiftly-1.1.1-x86_64.tar.gz"
target=swiftly.tar.gz
DownloadURL $url_cached $url $checksum $target

tar zxf swiftly.tar.gz
./swiftly init --quiet-shell-followup -y
# The installer leaves out line feed when modifying .profile
echo " " >> /home/qt/.profile
