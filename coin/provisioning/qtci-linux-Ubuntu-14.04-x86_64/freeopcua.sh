#!/bin/env bash

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

sudo apt-get update
sudo apt-get install -y libboost-dev libboost-thread-dev libboost-system-dev libboost-program-options-dev libboost-filesystem-dev libxml2-dev libboost-regex-dev

TEMPDIR=$(mktemp --directory) || echo "Failed to create temporary directory"
trap "sudo rm -fr $TEMPDIR" EXIT
cd $TEMPDIR
git clone https://github.com/FreeOpcUa/freeopcua.git freeopcua
cd freeopcua
git checkout 57b6993d39b6761af773fa4fa37c3fbd39c764f1
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local ..
make
sudo make install
