#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
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

# This script installs CMake

# CMake is needed for autotests that verify that Qt can be built with CMake

# shellcheck source=./InstallAppFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/InstallAppFromCompressedFileFromURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

PrimaryUrl="http://ci-files01-hki.intra.qt.io/input/mac/macos_10.13_high_sierra/cmake-3.11.3-Darwin-x86_64.tar.gz"
AltUrl="https://cmake.org/files/v3.11/cmake-3.11.3-Darwin-x86_64.tar.gz"
SHA1="3d13de8020ce560159fa5cecb669498c48552d96"
appPrefix="cmake-3.11.3-Darwin-x86_64"

InstallAppFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$appPrefix"

SetEnvVar "PATH" "/Applications/CMake.app/Contents/bin:\$PATH"

echo "CMake = 3.11.3" >> ~/versions.txt
