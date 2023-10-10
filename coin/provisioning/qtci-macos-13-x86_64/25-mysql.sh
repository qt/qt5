#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2022 The Qt Company Ltd.
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

# This script installs MySQL

# MySQL is needed for Qt to be able to support MySQL

set -ex

# shellcheck source=../common/macos/InstallAppFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../common/macos/InstallAppFromCompressedFileFromURL.sh"
# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"

PrimaryUrl="http://ci-files01-hki.intra.qt.io/input/mac/macos_10.12_sierra/mysql-5.7.15-osx10.11-x86_64.tar.gz"
AltUrl="https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.15-osx10.11-x86_64.tar.gz"
SHA1="07949bd42f350b0504a1536b8830b809b4a34fca"
appPrefix=""
targetDir="/opt/mysql57/"

sudo mkdir -p "/opt"

InstallAppFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$appPrefix" "$targetDir"

SetEnvVar "MYSQLBINPATH" "/opt/mysql57/bin"
echo "MySQL = 5.7.15" >> ~/versions.txt
