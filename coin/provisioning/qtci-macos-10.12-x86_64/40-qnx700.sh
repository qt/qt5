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

# This script installs QNX 7.

# shellcheck source=../common/unix/try_catch.sh
source "${BASH_SOURCE%/*}/../common/unix/try_catch.sh"

targetFolder="/opt/"
sourceFile="/net/ci-files01-hki.intra.qt.io/hdd/www/input/qnx/qnx700_mac.zip"
folderName="qnx700"

ExceptionExtract=100
ExceptionExtract2=101


try
(
    sudo mkdir -p "$targetFolder"

    echo "Extracting QNX 7"
    sudo unzip -q "$sourceFile" -d "$targetFolder" || throw $ExceptionExtract

    sudo chown -R qt:wheel "$targetFolder"/"$folderName"

    # Verify that we have last file in zip
    if [ ! -f $targetFolder/$folderName/qnxsdp-env.sh ]; then
        throw $ExceptionExtract2
    fi

    # Set env variables
    echo "export QNX_700=$targetFolder/$folderName" >> ~/.bashrc
    echo "QNX SDP = 7.0.0" >> ~/versions.txt
)
catch || {
        case $ex_code in
            $ExceptionExtract)
                echo "Failed to unzip QNX 7."
                exit 1;
            ;;
            $ExceptionExtract2)
                echo "The last file in the zip did not get extracted."
                exit 1;
            ;;
        esac
}

