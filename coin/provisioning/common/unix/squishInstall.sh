#!/usr/bin/env bash

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

source "${BASH_SOURCE%/*}/try_catch.sh"

set -ex

# This script will install squish package for Linux and Mac.
# Squish is need by Release Test Automation (RTA)

version="6.3.0"
# Branch version without dot
qtBranch="59x"
squishFolder="/opt/squish"
squishUrl="ci-files01-hki.intra.qt.io:/hdd/www/input/squish/coin/$qtBranch/"
squishFile="squish-$version-qt$qtBranch-linux64.run"
if uname -a |grep -q Darwin; then
     squishFile="squish-$version-qt$qtBranch-macx86_64.dmg"
fi

squishLicenseUrl="ci-files01-hki.intra.qt.io:/hdd/www/input/squish/coin/"
squishLicenseFile=".squish-3-license.tar.gz"

# These checks can be removed when Vanilla OS for all linux and Mac are in
if [ -d "$squishFolder" ]; then
    echo "Move old squish to /tmp"
    sudo mv "$squishFolder" "/tmp/squish_$(date)"
fi

if [ -f "/etc/profile.d/squish_env.sh" ]; then
    echo "Remove /etc/profile.d/squish_env.sh"
    sudo rm -f "/etc/profile.d/squish_env.sh"
    export SQUISH_LICENSEKEY_DIR=$HOME
fi

ExceptionMount=100
ExceptionCreateFolder=101
ExceptionUncompress=102
ExceptionUnknownFormat=103
ExceptionCopy=104
ExceptionUmount=105
ExceptionHdiutilAttach=106
ExceptionInstallSquish=107
ExceptionChangeOwnership=108

function MountAndInstall {

    url=$1
    targetDirectory=$2
    targetFile=$3

    # Check which platform
    if uname -a |grep -q Darwin; then
        usersGroup="staff"
        mountFolder="/Volumes"
        squishLicenseDir="/Users/qt"
    elif uname -a |grep -q "el6\|el7"; then
        usersGroup="qt"
        mountFolder="/tmp"
        squishLicenseDir="/root"
    elif uname -a |grep -q "Ubuntu"; then
        usersGroup="users"
        mountFolder="/tmp"
        squishLicenseDir="/home/qt"
    else
        usersGroup="users"
        mountFolder="/tmp"
        squishLicenseDir="/root"
    fi

    targetFileMount="$mountFolder"/"$targetFile"

    try
    (
        echo "Mounting $url to $mountFolder"
        sudo mount "$url" $mountFolder || throw $ExceptionMount
        echo "Create $targetDirectory if needed"
        if [ !  -d "/opt" ]; then
            sudo mkdir "/opt" || throw $ExceptionCreateFolder
        fi
        if [ !  -d "$targetDirectory" ]; then
            sudo mkdir "$targetDirectory" || throw $ExceptionCreateFolder
        fi
        echo "Uncompress $targetFile"
        if [[ $targetFile == *.tar.gz ]]; then
            if [[ $targetFile == .squish-3-license.* ]]; then
                target="$squishLicenseDir"
                # Squish license need to be exists also in users home directory, because squish check it before it starts running tests
                sudo tar -xzf "$targetFileMount" --directory "$HOME" || throw $ExceptionUncompress
            else
                target="$targetDirectory"
            fi
            sudo tar -xzf "$targetFileMount" --directory "$target" || throw $ExceptionUncompress
            echo "Unmounting $mountFolder"
            sudo umount $mountFolder || throw $ExceptionUmount
        elif [[ $targetFile == *.dmg ]]; then
            echo "'dmg-file', no need to uncompress"
            sudo cp $targetFileMount /tmp || throw $ExceptionCopy
            sudo umount $mountFolder || throw $ExceptionUmount
            sudo hdiutil attach "/tmp/$targetFile" || throw $ExceptionHdiutilAttach
            sudo /Volumes/froglogic\ Squish/Install\ Squish.app/Contents/MacOS/Squish unattended=1 targetdir="$targetDirectory/package" qtpath="$targetDirectory" || throw $ExceptionInstallSquish
            sudo hdiutil unmount /Volumes/froglogic\ Squish/
        elif [[ $targetFile == *.run ]]; then
            echo "'run-file', no need to uncompress"
            sudo cp $targetFileMount $targetDirectory || throw $ExceptionCopy
            sudo umount $mountFolder || throw $ExceptionUmount
            sudo $targetDirectory/$targetFile unattended=1 targetdir="$targetDirectory/package" qtpath="$targetDirectory" > /dev/null 2>&1 || throw $ExceptionInstallSquish
            sudo rm -fr "$targetDirectory/$targetFile"
            if uname -a |grep -q "Ubuntu"; then
                sudo mkdir /usr/lib/tcl8.6 || throw $ExceptionCreateFolder
                sudo cp "$targetDirectory/package/tcl/lib/tcl8.6/init.tcl" /usr/lib/tcl8.6/ || throw $ExceptionCopy
            fi
        else
            throw $ExceptionUnknownFormat
        fi

        echo "Changing ownerships"
        sudo chown -R qt:$usersGroup "$targetDirectory" || throw $ExceptionChangeOwnership
        sudo chown qt:$usersGroup "$HOME/.squish-3-license"

    )

    catch || {
        case $ex_code in
            $ExceptionMount)
                echo "Failed to mount $url to $mountFolder."
                exit 1;
            ;;
            $ExceptionCreateFolder)
                echo "Failed to create folder"
                exit 1;
            ;;
            $ExceptionUncompress)
                echo "Failed extracting compressed file."
                exit 1;
            ;;
            $ExceptionUnknownFormat)
                echo "Unknown file format."
                exit 1;
            ;;
            $ExceptionCopy)
                echo "Failed to copy"
                exit 1;
            ;;
            $ExceptionUmount)
                echo "Failed to unmount $mountFolder."
                exit 1;
            ;;
            $ExceptionHdiutilAttach)
                echo "Failed to hdituli attach $mountFolder/$targetFile."
                exit 1;
            ;;
            $ExceptionInstallSquish)
                echo "Failed to install squish"
                exit 1;
            ;;
            $ExceptionChangeOwnership)
                echo "Failed to change ownership of $targetDirectory."
                exit 1;
            ;;
        esac
    }
}

echo "Set commands for environment variables in .bashrc"

if uname -a |grep -q "Ubuntu"; then
    echo "export SQUISH_PATH=$squishFolder/package" >> ~/.profile
    echo "export PATH=\$PATH:$quishFolder/squish-$version/bin" >> ~/.profile
else
    echo "export SQUISH_PATH=$squishFolder/package" >> ~/.bashrc
    echo "export PATH=\$PATH:$quishFolder/squish-$version/bin" >> ~/.bashrc
fi

echo "Installing squish license to home directory.."
MountAndInstall "$squishLicenseUrl" "$squishFolder" "$squishLicenseFile"

echo "Installing squish $version.."
MountAndInstall "$squishUrl" "$squishFolder" "$squishFile"
