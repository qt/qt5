#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs MySQL

# MySQL is needed for Qt to be able to support MySQL

set -ex

# shellcheck source=../common/macos/InstallAppFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../common/macos/InstallAppFromCompressedFileFromURL.sh"
# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"

PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/mac/macos_10.12_sierra/mysql-5.7.15-osx10.11-x86_64.tar.gz"
AltUrl="https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.15-osx10.11-x86_64.tar.gz"
SHA1="07949bd42f350b0504a1536b8830b809b4a34fca"
appPrefix=""
targetDir="/opt/mysql57/"

sudo mkdir -p "/opt"

InstallAppFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$appPrefix" "$targetDir"

SetEnvVar "MYSQLBINPATH" "/opt/mysql57/bin"
echo "MySQL = 5.7.15" >> ~/versions.txt
