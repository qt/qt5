#!/bin/bash

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

# This script installs QNX 7.

targetFolder="/opt/"
sourceFile="/net/ci-files01-hki.intra.qt.io/hdd/www/input/qnx/qnx700-20190325-2-macos.tar.xz"
folderName="qnx700"

sudo mkdir -p "$targetFolder"

echo "Extracting QNX 7"
sudo tar -C "$targetFolder" -Jxf $sourceFile

sudo chown -R qt:wheel "$targetFolder"/"$folderName"

# Verify that we have last file in zip
if [ ! -f $targetFolder/$folderName/qnxsdp-env.sh ]; then
    exit 1
fi

# Set env variables
echo "export QNX_700=$targetFolder/$folderName" >> ~/.bashrc
echo "QNX SDP = 7.0.0" >> ~/versions.txt
