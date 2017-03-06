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

# This script installs Xcode
# Prerequisites: Have Xcode prefetched to local cache as xz compressed.
# This can be achieved by fetching Xcode_8.xip from Apple Store.
# Uncompress it with 'xar -xf Xcode_8.xip'
# Then get https://gist.githubusercontent.com/pudquick/ff412bcb29c9c1fa4b8d/raw/24b25538ea8df8d0634a2a6189aa581ccc6a5b4b/parse_pbzx2.py
# with which you can run 'python parse_pbzx2.py Content'.
# This will give you a file called "Content.part00.cpio.xz" that
# can be renamed to Xcode_8.xz for this script.



# shellcheck source=../common/try_catch.sh
source "${BASH_SOURCE%/*}/../common/try_catch.sh"

ExceptionDownloadUrl=100
ExceptionSHA1=101
ExceptionUnXZ=102
ExceptionCPIO=103
ExceptionDelete=104


url=http://ci-files01-hki.ci.local/input/mac/Xcode_8.2.xz
targetFile=/tmp/Xcode_8.2.xz
expectedSha1=46edc920955e315d946e36c45f629d5ee9dc9d59

try
(
    echo "Downloading Xcode from primary URL '$url'"
    curl --fail -L --retry 5 --retry-delay 5 -o "$targetFile" "$url" || throw $ExceptionDownloadUrl

    echo "Checking SHA1 on $targetFile"
    echo "$expectedSha1 *$targetFile" | shasum --check || throw $ExceptionSHA1

    echo "Uncompressing '$targetFile'"
    xz -d "$targetFile" || throw $ExceptionUnXZ

    echo "Unarchiving '${targetFile%.*}'"
    (cd /Applications/ && sudo cpio -dmiI "${targetFile%.*}") || throw $ExceptionCPIO

    echo "Deleting '${targetFile%.*}'"
    rm "${targetFile%.*}" || throw $ExceptionDelete

    echo "Xcode = 8.2" >> ~/versions.txt
)
catch || {
    case $ex_code in
        $ExceptionDownloadUrl)
            echo "Failed to download Xcode."
            exit 1;
        ;;
        $ExceptionSHA1)
            echo "Failed to check SHA1."
            exit 1;
        ;;
        $ExceptionUnXZ)
            echo "Failed to uncompress .xz"
            exit 1;
        ;;
        $ExceptionCPIO)
            echo "Failed to unarchive .cpio."
            exit 1;
        ;;
        $ExceptionDelete)
            echo "Failed to delete temporary file."
            exit 1;
        ;;

    esac
}


