#!/usr/bin/env bash
# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=./DownloadURL.sh
source "${BASH_SOURCE%/*}/DownloadURL.sh"

set -ex

# This script will fetch and extract pre-buildt squish package for Linux and Mac.
# Squish is need by Release Test Automation (RTA)

version="7.0.1"
qtBranch="63x"
installFolder="/opt"
squishFolder="$installFolder/squish"
preBuildCacheUrl="ci-files01-hki.ci.qt.io:/hdd/www/input/squish/jenkins_build/stable"
licenseFile=".squish-license"
licenseUrl="http://ci-files01-hki.ci.qt.io/input/squish/coin/$qtBranch/$licenseFile"
licenseSHA="e84b499a2011f9bb1a6eefc7b2338d7ae770927a"
if uname -a |grep -q Darwin; then
    compressedFolder="prebuild-squish-$version-$qtBranch-mac.tar.gz"
    sha1="ed8aa2e902808741fb9496a0d339d4c145530eef"
else
     compressedFolder="prebuild-squish-$version-$qtBranch-linux64.tar.gz"
     sha1="a9de35bba9b4dd9afabdde4df14564428745a979"
fi

mountFolder="/tmp/squish"
sudo mkdir "$mountFolder"

# Check which platform
if uname -a |grep -q Darwin; then
    usersGroup="staff"
#    squishLicenseDir="/Users/qt"
elif uname -a |grep -q "el7"; then
    usersGroup="qt"
#    squishLicenseDir="/root"
elif uname -a |grep -q "Ubuntu"; then
    usersGroup="users"
#    squishLicenseDir="/home/qt"
else
    usersGroup="users"
#    squishLicenseDir="/root"
fi

targetFileMount="$mountFolder"/"$compressedFolder"

echo "Mounting $preBuildCacheUrl to $mountFolder"
if uname -a |grep -q Darwin; then
   sudo mount -o locallocks "$preBuildCacheUrl" "$mountFolder"
else
   sudo mount "$preBuildCacheUrl" "$mountFolder"
fi
echo "Create $installFolder if needed"
if [ !  -d "$installFolder" ]; then
    sudo mkdir "$installFolder"
fi

VerifyHash "$targetFileMount" "$sha1"

echo "Uncompress $compressedFolder"
sudo tar -xzf "$targetFileMount" --directory "$installFolder"

echo "Unmounting $mountFolder"
sudo diskutil unmount force "$mountFolder" || sudo umount -f "$mountFolder" || true

sudo mv "$installFolder/rta_squish_$qtBranch" "$squishFolder"
if uname -a |grep -q Darwin; then
    sudo xattr -r -c "$squishFolder"
fi

if uname -a |grep -q "Ubuntu"; then
    if [ ! -e "/usr/lib/tcl8.6" ]; then
        sudo mkdir /usr/lib/tcl8.6
        #this needs to be copied only to squish_for_qt62
        sudo cp "$squishFolder/squish_for_qt62/tcl/lib/tcl8.6/init.tcl" /usr/lib/tcl8.6/
    fi
fi


DownloadURL "$licenseUrl" "$licenseUrl" "$licenseSHA" "$HOME/$licenseFile"

echo "Changing ownerships"
sudo chown -R qt:$usersGroup "$squishFolder"
sudo chown qt:$usersGroup "$HOME/$licenseFile"

echo "Set commands for environment variables in .bashrc"
if uname -a |grep -q "Ubuntu"; then
    echo "export SQUISH_PATH=$squishFolder/squish_for_qt62" >> ~/.profile
    echo "export PATH=\$PATH:$squishFolder/squish_for_qt62/bin" >> ~/.profile
else
    echo "export SQUISH_PATH=$squishFolder/squish_for_qt63" >> ~/.bashrc
    echo "export PATH=\$PATH:$squishFolder/squish_for_qt63/bin" >> ~/.bashrc
fi

echo "Verifying Squish, available installations:"
ls -la $squishFolder

if "$squishFolder/squish_for_qt62/bin/squishrunner" --testsuite "$squishFolder/suite_test_squish" | grep "Squish test run successfully" ; then
  echo "Squish for Qt6.3 installation tested successfully"
else
  echo "Squish for Qt6.3 test failed! Package wasn't installed correctly."
  exit 1
fi
if "$squishFolder/squish_for_qt63/bin/squishrunner" --testsuite "$squishFolder/suite_test_squish" | grep "Squish test run successfully" ; then
  echo "Squish for Qt6.2 installation tested successfully"
else
  echo "Squish for Qt6.2 test failed! Package wasn't installed correctly."
  exit 1
fi


