#!/bin/bash

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

# This script installs INTEGRITY

source "${BASH_SOURCE%/*}/../common/InstallFromCompressedFileFromURL.sh"

version="11.4.4"
PrimaryUrl="http://ci-files01-hki.ci.local/input/integrity/ghs_$version.tar.gz"
AltUrl="$PrimaryUrl" # we lack an external source for this
SHA1="4afa3c15e13c91734951b73f6b21388294c5d794"
targetFolder="/opt/ghs"
appPrefix=""

InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$targetFolder" "$appPrefix"

echo "export INTEGRITY_BSP=platform-cortex-a9" >> ~/.bashrc
echo "export INTEGRITY_PATH=$targetFolder/comp_201654" >> ~/.bashrc
echo "export INTEGRITY_DIR=$targetFolder/int1144" >> ~/.bashrc
echo "export INTEGRITY_GL_INC_DIR=\$INTEGRITY_DIR/INTEGRITY-include/Vivante/sdk/inc" >> ~/.bashrc
echo "export INTEGRITY_GL_LIB_DIR=\$INTEGRITY_DIR/libs/Vivante" >> ~/.bashrc

echo "INTEGRITY = $version" >> ~/versions.txt
