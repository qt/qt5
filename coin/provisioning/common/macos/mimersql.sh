#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs Mimer SQL

# Mimer SQL is needed for Qt to be able to support Mimer SQL

set -ex

source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"

arch=$(uname -m)

mimerSqlVersion="11.0.7G"
if [ "$arch" = "x86_64" ]; then
    mimerSqlPackageName="mimersql-${mimerSqlVersion}-x86.pkg"
    SHA1="e8129e66cef8a1cf6639895963ce6155e0acfa90"
else
    mimerSqlPackageName="mimersql-${mimerSqlVersion}-macosarm_64.pkg"
    SHA1="82ded8637e5ba79532b552dcfb385d158d6abf74"
fi


PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/mac/$mimerSqlPackageName"
AltUrl="https://install.mimer.com/qt/macOS/$mimerSqlPackageName"
appPrefix=""

DownloadURL "$PrimaryUrl" "$AltUrl" "$SHA1" "/tmp/$mimerSqlPackageName"

echo "Installing $mimerSqlPackageName"
sudo installer -pkg /tmp/$mimerSqlPackageName -target /

echo "Removing $mimerSqlPackageName"
rm "/tmp/$mimerSqlPackageName"

echo "Mimer SQL = $mimerSqlVersion" >> ~/versions.txt
