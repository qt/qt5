#!/usr/bin/env bash
# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs PostgreSQL

# PostgreSQL is needed for Qt to be able to support PostgreSQL

set -ex

# shellcheck source=../common/macos/InstallAppFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../common/macos/InstallAppFromCompressedFileFromURL.sh"
# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"

psqlVersion="9.6.0"

PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/mac/macos_10.12_sierra/Postgres-$psqlVersion.zip"
AltUrl="https://github.com/PostgresApp/PostgresApp/releases/download/$psqlVersion/Postgres-$psqlVersion.zip"
SHA1="5078e44663787006ca55fa3b5e2be598bed82eb5"
appPrefix=""

InstallAppFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$appPrefix"

SetEnvVar "POSTGRESQLBINPATH" "/Applications/Postgres.app/Contents/Versions/9.6/bin"
echo "PostgreSQL = $psqlVersion" >> ~/versions.txt
