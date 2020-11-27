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

# This script installs QNX 7.

set -ex

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

DownloadAndExtract () {
    url=$1
    sha=$2
    file=$3
    folder=$4

    DownloadURL "$url" "$url" "$sha" "$file"
    sudo tar -C $folder -Jxf $file

    rm -rf $file
}

targetFolder="/opt/"
folderName="qnx710"
targetPath="$targetFolder$folderName"

if [ ! -d "$targetFolder" ]; then
    mkdir -p $targetFolder
fi

# QNX SDP
sourceFile="http://ci-files01-hki.intra.qt.io/input/qnx/qnx710-20201027-linux.tar.xz"
targetFile="qnx710.tar.xz"
sha1="fa9eb0f4247504a546cb014784646847eb6c8114"
DownloadAndExtract "$sourceFile" "$sha1" "$targetFile" "$targetFolder"

# Toolchain files
sourceFile="http://ci-files01-hki.intra.qt.io/input/qnx/qnx-toolchains.tar.xz"
targetFile="qnx-toolchains.tar.xz"
sha1="d8a97605d80a2296f98caba3854557ca0dd5d7d3"
DownloadAndExtract "$sourceFile" "$sha1" "$targetFile" "$targetPath"

sudo chown -R qt:users "$targetPath"

# Verify that we have last files in tars
if [ ! -f $targetPath/qnxsdp-env.sh ] || [ ! -f $targetPath/qnx-toolchain-x8664.cmake ]
then
    echo "QNX toolchain installation failed!"
    exit -1
fi

# Set env variables
SetEnvVar "QNX_710" "$targetPath"

echo "QNX SDP = 7.1.0" >> ~/versions.txt
