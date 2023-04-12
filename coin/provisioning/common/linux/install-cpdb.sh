#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2023 The Qt Company Ltd.
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

# This script install cpdb from sources.
# Requires GCC and Perl to be in PATH.
# The following dependencies should be pre-installed:
#  make, autoconf, autopoint, libglib2.0-dev, libdbus-1-dev, libtool
set -ex

repName="cpdb-libs"
gitUrl="https://github.com/openprinting/$repName.git"
tmpdir="/tmp"
repDir="$tmpdir/$repName"
prefix="/usr"
rm -rf $repDir
cd $tmpdir
git clone --depth 1 $gitUrl >/dev/null
cd $repDir
# cpdb-libs v2.0b4 with build bug fixed
git checkout ce848f1571a82ec03881fce127ff28bec8da239e > /dev/null
./autogen.sh > /dev/null
./configure --prefix=$prefix > /dev/null
make -j$(nproc) > /dev/null && sudo make install > /dev/null
sudo ldconfig
rm -rf $repDir
