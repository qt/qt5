#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2020 The Qt Company Ltd.
## Contact: https://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see https://www.qt.io/terms-conditions. For further
## information use the contact form at https://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 3 as published by the Free Software
## Foundation and appearing in the file LICENSE.LGPL3 included in the
## packaging of this file. Please review the following information to
## ensure the GNU Lesser General Public License version 3 requirements
## will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 2.0 or (at your option) the GNU General
## Public license version 3 or any later version approved by the KDE Free
## Qt Foundation. The licenses are as published by the Free Software
## Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
## included in the packaging of this file. Please review the following
## information to ensure the GNU General Public License requirements will
## be met: https://www.gnu.org/licenses/gpl-2.0.html and
## https://www.gnu.org/licenses/gpl-3.0.html.
##
## $QT_END_LICENSE$
##
#############################################################################

# This script installs PostgreSQL

# PostgreSQL is needed for Qt to be able to support PostgreSQL

set -ex

# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"
# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"

psqlAppVersion="2.5"
psqlVersion="14"

packageName="Postgres-$psqlAppVersion-$psqlVersion.dmg"

PrimaryUrl="http://ci-files01-hki.intra.qt.io/input/mac/macos_10.12_sierra/$packageName"
AltUrl="https://github.com/PostgresApp/PostgresApp/releases/download/v$psqlAppVersion/$packageName"
SHA1="04cb6939704c5ede5646c1da8a686da3ded98a26"
appPrefix=""

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
