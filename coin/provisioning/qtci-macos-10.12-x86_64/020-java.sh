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

# This script installs JDK
echo "Installing Java Development Kit"

# shellcheck source=../common/try_catch.sh
source "${BASH_SOURCE%/*}/../common/try_catch.sh"

ExceptionDownloadPrimaryUrl=100
ExceptionDownloadAltUrl=101
ExceptionSHA1=102
ExceptionAttachImage=103
ExceptionInstall=104
ExceptionDetachImage=105
ExceptionRemoveTmpFile=106
ExceptionDisableAutoUpdate=107


url=http://ci-files01-hki.ci.local/input/mac/macos_10.12_sierra/jdk-8u102-macosx-x64.dmg
url_alt=http://download.oracle.com/otn-pub/java/jdk/8u102-b14/jdk-8u102-macosx-x64.dmg
targetFile=/tmp/jdk-8u102-macosx-x64.dmg
expectedSha1=1405af955f14e32aae187b5754a716307db22104

try
(
    try
    (
        echo "Downloading from primary URL '$url'"
        curl --fail -L --retry 5 --retry-delay 5 -o "$targetFile" "$url" || throw $ExceptionDownloadPrimaryUrl
    )
    catch || {
        case $ex_code in
            $ExceptionDownloadPrimaryUrl)
                echo "Failed to download '$url' multiple times"
                echo "Downloading tar.gz from alternative URL '$url_alt'"
                curl --fail -L --retry 5 --retry-delay 5 -j -k -H "Cookie: oraclelicense=accept-securebackup-cookie" -o "$targetFile" "$url_alt" || throw $ExceptionDownloadAltUrl
            ;;
        esac
    }
    echo "Checking SHA1 on '$targetFile'"
    echo "$expectedSha1 *$targetFile" | shasum --check || throw $ExceptionSHA1

    echo Mounting DMG
    hdiutil attach "$targetFile" || throw $ExceptionAttachImage

    echo Installing JDK
    (cd /Volumes/JDK\ 8\ Update\ 102/ && sudo installer -package JDK\ 8\ Update\ 102.pkg -target /) || throw $ExceptionInstall

    disk=`hdiutil info | grep '/Volumes/JDK 8 Update 102' | awk '{print $1}'`
    hdiutil detach $disk || throw $ExceptionDetachImage

    echo "Removing temporary file '$targetFile'"
    rm "$targetFile" || throw $ExceptionRemoveTmpFile

    echo "Disable auto update"
    sudo defaults write /Library/Preferences/com.oracle.java.Java-Updater JavaAutoUpdateEnabled -bool false || throw $ExceptionDisableAutoUpdate

    echo "JDK Version = 8 update 102" >> ~/versions.txt
)
catch || {
    case $ex_code in
        $ExceptionDownloadPrimaryUrl)
            echo "Failed to download JDK from primary URL."
            exit 1;
        ;;
        $ExceptionDownloadAltUrl)
            echo "Failed to download JDK from alternative URL."
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
            echo "Failed to install JDK."
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
        $ExceptionDisableAutoUpdate)
            echo "Failed to disable auto update."
            exit 1;
        ;;

    esac
}
