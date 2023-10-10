#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs Mimer SQL

# Mimer SQL is needed for Qt to be able to support Mimer SQL

set -ex
os="$1"

source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"

mimerSqlVersion="11.0.7G"
if [ "$os" = "macos" ]; then
    arch=$(uname -m)
    if [ "$arch" = "x86_64" ]; then
        mimerSqlPackageName="mimersql-110_x86_64.tgz"
        SHA1="d748f87b72e7188c527f131db2590f552f18f544"
    else
        mimerSqlPackageName="mimersql-110_arm64.tgz"
        SHA1="f209c97074d096e50e637441073e8aa355c5116e"
    fi
else
    mimerSqlPackageName="mimersql-110_universal.tgz"
    SHA1="eab32be623f1cbde7c29cea0f0ca4332b8ca502b"
fi

PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/mac/$mimerSqlPackageName"
AltUrl="https://install.mimer.com/qt/macOS/$mimerSqlPackageName"
appPrefix=""

DownloadURL "$PrimaryUrl" "$AltUrl" "$SHA1" "/tmp/$mimerSqlPackageName"

echo "Installing $mimerSqlPackageName"
tar -C /usr/local -zxf /tmp/$mimerSqlPackageName

echo "Removing $mimerSqlPackageName"
rm "/tmp/$mimerSqlPackageName"

echo "Mimer SQL = $mimerSqlVersion" >> ~/versions.txt
