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

# This script installs Command Line Tools for Xcode
# Prerequisite: Get the .dmg file from Apple Store beforehand to local cache

# shellcheck source=../common/try_catch.sh
source "${BASH_SOURCE%/*}/../common/try_catch.sh"

ExceptionDownloadUrl=100
ExceptionSHA1=101
ExceptionAttachImage=102
ExceptionInstall=103
ExceptionDetachImage=104
ExceptionRemoveTmpFile=105
ExceptionAcceptLicense=106


url=http://ci-files01-hki.ci.local/input/mac/Command_Line_Tools_macOS_10.11_for_Xcode_8.2.dmg
targetFile=/tmp/Command_Line_Tools_macOS_10.11_for_Xcode_8.2.dmg
expectedSha1=4df615ca765ac1a1e681ddcbca79fc15990e3b25

try
(
    echo "Downloading Command Line Tools from URL '$url'"
    curl --fail -L --retry 5 --retry-delay 5 -o "$targetFile" "$url" || throw $ExceptionDownloadUrl

    echo "Checking SHA1 on '$targetFile'"
    echo "$expectedSha1 *$targetFile" | shasum --check || throw $ExceptionSHA1

    echo Mounting DMG
    hdiutil attach "$targetFile" || throw $ExceptionAttachImage

    echo Installing Command Line Tools
    (cd /Volumes/Command\ Line\ Developer\ Tools/ && sudo installer -pkg "Command Line Tools (macOS El Capitan version 10.11).pkg" -target /) || throw $ExceptionInstall

    hdiutil detach /dev/disk1s1 || throw $ExceptionDetachImage

    echo "Removing temporary file '$targetFile'"
    rm "$targetFile" || throw $ExceptionRemoveTmpFile

    echo "Accept license"
    sudo xcodebuild -license accept || throw $ExceptionAcceptLicense

    echo "Command Line Tools = 8.2" >> ~/versions.txt
)
catch || {
    case $ex_code in
        $ExceptionDownloadUrl)
            echo "Failed to download Command Line Tools from form URL '$url'."
            exit 1;
        ;;
        $ExceptionSHA1)
            echo "Failed to check SHA1."
            exit 1;
        ;;
        $ExceptionAttachImage)
            echo "Failed to attach image."
            exit 1;
        ;;
        $ExceptionInstall)
            echo "Failed to install Command Line Tools."
            exit 1;
        ;;
        $ExceptionDetachImage)
            echo "Failed to detach image."
            exit 1;
        ;;
        $ExceptionRemoveTmpFile)
            echo "Failed to remove temporary file."
            exit 1;
        ;;
        $ExceptionAcceptLicense)
            echo "Failed to accept license."
            exit 1;
        ;;

    esac
}
