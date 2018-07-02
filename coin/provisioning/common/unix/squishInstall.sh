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

testSuite="suite_test_squish"
testSuiteUrl="ci-files01-hki.intra.qt.io:/hdd/www/input/squish/coin/"

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

    function UnMount {
        echo "Unmounting $mountFolder"
        sudo diskutil unmount force "$mountFolder" || sudo umount -f "$mountFolder"
    }

    targetFileMount="$mountFolder"/"$targetFile"

    echo "Mounting $url to $mountFolder"
    sudo mount "$url" "$mountFolder"
    echo "Create $targetDirectory if needed"
    if [ !  -d "/opt" ]; then
        sudo mkdir "/opt"
    fi
    if [ !  -d "$targetDirectory" ]; then
        sudo mkdir "$targetDirectory"
    fi
    echo "Uncompress $targetFile"
    if [[ $targetFile == *.tar.gz ]]; then
        if [[ $targetFile == .squish-3-license.* ]]; then
            target="$squishLicenseDir"
            # Squish license need to be exists also in users home directory, because squish check it before it starts running tests
            sudo tar -xzf "$targetFileMount" --directory "$HOME"
        else
            target="$targetDirectory"
        fi
        sudo tar -xzf "$targetFileMount" --directory "$target"
        UnMount
    elif [[ $targetFile == *.dmg ]]; then
        echo "'dmg-file', no need to uncompress"
        sudo cp $targetFileMount /tmp
        UnMount
        sudo hdiutil attach "/tmp/$targetFile"
        sudo /Volumes/froglogic\ Squish/Install\ Squish.app/Contents/MacOS/Squish unattended=1 targetdir="$targetDirectory/package" qtpath="$targetDirectory"
        mountFolder="/Volumes/froglogic Squish"
        UnMount
    elif [[ $targetFile == *.run ]]; then
        echo "'run-file', no need to uncompress"
        sudo cp $targetFileMount $targetDirectory
        UnMount
        sudo $targetDirectory/$targetFile unattended=1 targetdir="$targetDirectory/package" qtpath="$targetDirectory" > /dev/null 2>&1
        sudo rm -fr "$targetDirectory/$targetFile"
        if uname -a |grep -q "Ubuntu"; then
            sudo mkdir /usr/lib/tcl8.6
            sudo cp "$targetDirectory/package/tcl/lib/tcl8.6/init.tcl" /usr/lib/tcl8.6/
        fi
    else
        exit 1
    fi

    echo "Changing ownerships"
    sudo chown -R qt:$usersGroup "$targetDirectory"
    sudo chown qt:$usersGroup "$HOME/.squish-3-license"
}

echo "Set commands for environment variables in .bashrc"

if uname -a |grep -q "Ubuntu"; then
    echo "export SQUISH_PATH=$squishFolder/package" >> ~/.profile
    echo "export PATH=\$PATH:$squishFolder/squish-$version/bin" >> ~/.profile
else
    echo "export SQUISH_PATH=$squishFolder/package" >> ~/.bashrc
    echo "export PATH=\$PATH:$squishFolder/squish-$version/bin" >> ~/.bashrc
fi

echo "Installing squish license to home directory.."
MountAndInstall "$squishLicenseUrl" "$squishFolder" "$squishLicenseFile"

echo "Installing squish $version.."
MountAndInstall "$squishUrl" "$squishFolder" "$squishFile"

echo "Installing test suite for squish"
MountAndInstall "$testSuiteUrl" "$squishFolder" "$testSuite.tar.gz"

echo "Verifying Squish Installation"
if "$squishFolder/package/bin/squishrunner" --testsuite "$squishFolder/$testSuite" | grep "Squish test run successfully" ; then
    echo "Squish installation tested successfully"
else
    echo "Squish test failed! Package wasn't installed correctly."
    exit 1
fi
