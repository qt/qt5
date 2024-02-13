#!/usr/bin/env bash
# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=./DownloadURL.sh
source "${BASH_SOURCE%/*}/DownloadURL.sh"

set -ex

# This script will fetch and extract pre-buildt squish package for Linux and Mac.
# Squish is need by Release Test Automation (RTA)

version="7.2.1"
qtBranch="66x"
installFolder="/opt"
squishFolder="$installFolder/squish"
preBuildCacheUrl="ci-files01-hki.ci.qt.io:/hdd/www/input/squish/jenkins_build/stable"
licenseFile=".squish-license"
licenseBranch="squish_license"
licenseUrl="http://ci-files01-hki.ci.qt.io/input/squish/coin/$licenseBranch/$licenseFile"
licenseSHA="e84b499a2011f9bb1a6eefc7b2338d7ae770927a"
testSuiteUrl="ci-files01-hki.ci.qt.io:/hdd/www/input/squish/coin/suite_test_squish"
testSuiteLocal="/tmp/squish_test_suite"
if uname -a |grep -q Darwin; then
    compressedFolder="prebuild-squish-$version-$qtBranch-mac.tar.gz"
    sha1="7467c974b65255c86b8fccaeca90e0590d4f7c96"
else
     compressedFolder="prebuild-squish-$version-$qtBranch-linux64.tar.gz"
     sha1="950a6035c777c8ce0a50a0b3ad468044d07f898b"
fi

mountFolder="/tmp/squish"
sudo mkdir "$mountFolder"
sudo mkdir "$testSuiteLocal"

# Check which platform
if uname -a |grep -q Darwin; then
    usersGroup="staff"
elif uname -a |grep -q "el7"; then
    usersGroup="qt"
elif uname -a |grep -q "Ubuntu"; then
    usersGroup="users"
else
    usersGroup="users"
fi

targetFileMount="$mountFolder"/"$compressedFolder"

echo "Mounting Squish packages from $preBuildCacheUrl to $mountFolder"
echo "Mounting Squish test suite from $testSuiteUrl to $testSuiteLocal"
if uname -a |grep -q Darwin; then
   sudo mount -o locallocks "$preBuildCacheUrl" "$mountFolder"
   sudo mount -o locallocks "$testSuiteUrl" "$testSuiteLocal"
else
   sudo mount "$preBuildCacheUrl" "$mountFolder"
   sudo mount "$testSuiteUrl" "$testSuiteLocal"
fi
echo "Create $installFolder if needed"
if [ !  -d "$installFolder" ]; then
    sudo mkdir "$installFolder"
fi

VerifyHash "$targetFileMount" "$sha1"

echo "Uncompress $compressedFolder"
sudo tar -xzf "$targetFileMount" --directory "$installFolder"

if uname -a |grep -q Darwin; then
    sudo xattr -r -c "$squishFolder"
fi

if uname -a |grep -q "Ubuntu"; then
    if [ ! -e "/usr/lib/tcl8.6" ]; then
        sudo mkdir /usr/lib/tcl8.6
        #this needs to be copied only to squish_for_qt65
        sudo cp "$squishFolder/squish_for_qt66/tcl/lib/tcl8.6/init.tcl" /usr/lib/tcl8.6/
    fi
fi

echo "Download Squish license"
DownloadURL "$licenseUrl" "$licenseUrl" "$licenseSHA" "$HOME/$licenseFile"

echo "Changing ownerships"
sudo chown -R qt:$usersGroup "$squishFolder"
sudo chown qt:$usersGroup "$HOME/$licenseFile"


echo "Verifying Squish, available installations:"
ls -la $squishFolder
cd $squishFolder

for squishInstallation in */ ; do
  if "$squishInstallation/bin/squishrunner" --testsuite "$testSuiteLocal" | grep "Squish test run successfully" ; then
    echo "Squish in $squishInstallation tested successfully"
  else
    echo "Testing Squish in $squishInstallation failed! Squish wasn't installed correctly."
    exit 1
  fi
done

echo "Clean up installation temp dirs"
echo "- Unmounting $mountFolder"
sudo diskutil unmount force "$mountFolder" || sudo umount -f "$mountFolder" || true

echo "- Unmounting $testSuiteLocal"
sudo diskutil unmount force "$testSuiteLocal" || sudo umount -f "$testSuiteLocal" || true
