#!/bin/bash

#############################################################################
##
## Copyright (C) 2016 The Qt Company Ltd.
## Contact: http://www.qt.io/licensing/
##
## This file is part of the test suite of the Qt Toolkit.
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

# This script installs CMake 3.6.2

# CMake is needed for autotests that verify that Qt can be built with CMake

# shellcheck source=../common/InstallFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../common/InstallFromCompressedFileFromURL.sh"

version="3.6.2"
PrimaryUrl="http://ci-files01-hki.ci.local/input/cmake/cmake-3.6.2-Linux-x86_64.tar.gz"
AltUrl="https://cmake.org/files/v3.6/cmake-3.6.2-Linux-x86_64.tar.gz"
SHA1="dd9d8d57b66109d4bac6eef9209beb94608a185c"
targetFolder="/opt/cmake-$version"
appPrefix="cmake-$version-Linux-x86_64"

InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$targetFolder" "$appPrefix"

echo "Adding $targetFolder/bin to PATH"
echo "export PATH=$targetFolder/bin:$PATH" >> ~/.bashrc
