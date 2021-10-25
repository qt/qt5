#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2021 The Qt Company Ltd.
## Contact: http://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL21$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see http://www.qt.io/terms-conditions. For further
## information use the contact form at http://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 2.1 or version 3 as published by the Free
## Software Foundation and appearing in the file LICENSE.LGPLv21 and
## LICENSE.LGPLv3 included in the packaging of this file. Please review the
## following information to ensure the GNU Lesser General Public License
## requirements will be met: https://www.gnu.org/licenses/lgpl.html and
## http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
##
## As a special exception, The Qt Company gives you certain additional
## rights. These rights are described in The Qt Company LGPL Exception
## version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
##
## $QT_END_LICENSE$
##
#############################################################################

# This script installs needed toolchains for INTEGRITY

# shellcheck source=../unix/InstallFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../unix/InstallFromCompressedFileFromURL.sh"
# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

urlToolchainEs7="http://ci-files01-hki.intra.qt.io/input/integrity/integrity_toolchain_es7_25102021.zip"
urlLibeglmegapack="http://ci-files01-hki.intra.qt.io/input/integrity/integrity_libeglmegapack.zip"
SHA1_toolchainEs7="13f634213187d94f70d184c6af38eb38f0bf44f0"
SHA1_Libeglmegapack="7f8ca64132eaea66202ea8db7f71f3300aab0777"
targetFolder="$HOME"
appPrefix=""

toolchain_file="${BASH_SOURCE%/*}/cmake_toolchain_files/integrity_toolchain.cmake"

echo "Install Integrity toolchain es7"
InstallFromCompressedFileFromURL "$urlToolchainEs7" "$urlToolchainEs7" "$SHA1_toolchainEs7" "$targetFolder" "$appPrefix"

echo "Install Integrity toolchain addons"
DownloadURL "$urlLibeglmegapack" "$urlLibeglmegapack" "$SHA1_Libeglmegapack" "/tmp/integrity_libeglmegapack.zip"
unzip "/tmp/integrity_libeglmegapack.zip" -d "/tmp"
mv /tmp/toolchain/* $targetFolder/toolchain
mv $targetFolder/toolchain $targetFolder/integrity_toolchain
cp $toolchain_file "$targetFolder/integrity_toolchain/toolchain.cmake"
sudo rm -fr /tmp/toolchain
