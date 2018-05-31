#!/bin/env bash

#############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
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

set +e

# shellcheck disable=SC1090

# We need to source to be able to use cmake in the shell
if uname -a |grep -q "Ubuntu"; then
    source ~/.profile
else
    source ~/.bashrc
fi

set -ex

# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

TEMPDIR=$(mktemp --directory) || echo "Failed to create temporary directory"
# shellcheck disable=SC2064
trap "sudo rm -fr $TEMPDIR" EXIT
cd "$TEMPDIR"

sudo pip install --upgrade pip
sudo pip install six

git clone https://github.com/open62541/open62541.git open62541
cd open62541
git checkout 8845e493d7751fd4eee3917b540e5346646b9cf7
mkdir build
cd build
cmake -DUA_ENABLE_AMALGAMATION=ON -DUA_ENABLE_METHODCALLS=ON -DCMAKE_INSTALL_PREFIX:PATH=/usr/local -DLIB_INSTALL_DIR:PATH=/usr/local/lib/open62541 ..
make

sudo make install
sudo /sbin/ldconfig

SetEnvVar "QTOPCUA_OPEN62541_LIB_PATH" "/usr/local/lib/open62541"
SetEnvVar "QTOPCUA_OPEN62541_INCLUDE_PATH" "/usr/local/include/open62541"

