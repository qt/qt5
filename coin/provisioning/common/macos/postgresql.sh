#!/usr/bin/env bash
# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs PostgreSQL

# PostgreSQL is needed for Qt to be able to support PostgreSQL

set -ex

# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"
# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"

psqlAppVersion="2.5"
psqlVersion="14"

packageName="Postgres-$psqlAppVersion-$psqlVersion.dmg"

PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/mac/macos_10.12_sierra/$packageName"
AltUrl="https://github.com/PostgresApp/PostgresApp/releases/download/v$psqlAppVersion/$packageName"
SHA1="04cb6939704c5ede5646c1da8a686da3ded98a26"

DownloadURL "$PrimaryUrl" "$AltUrl" "$SHA1" "/tmp/$packageName"

mountpoint="/tmp/pg-mount"
mkdir -p "$mountpoint"

echo "Mounting $packageName in $mountpoint"
hdiutil attach -nobrowse -mountpoint "$mountpoint" "/tmp/$packageName"

rm -Rf /Applications/Postgres.app
cp -Rf "$mountpoint/Postgres.app" /Applications

umount "$mountpoint"
echo "Removing $packageName"
rm "/tmp/$packageName"

SetEnvVar "POSTGRESQLBINPATH" "/Applications/Postgres.app/Contents/Versions/$psqlVersion/bin"
echo "PostgreSQL = $psqlVersion ($psqlAppVersion)" >> ~/versions.txt
