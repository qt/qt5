#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs JDK

set -ex

source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"

echo "Installing Java Development Kit"
version=21.0.9
targetFile=jdk-${version}_macos-x64_bin.dmg
expectedHash="3df8761bfba8d6a4633ecc92f1eff0a58d79c304"

url=ci-files01-hki.ci.qt.io:/hdd/www/input/mac
# url_alt=https://download.oracle.com/java/21/archive/jdk-21.0.8_macos-x64_bin.dmg

echo "Mounting $targetFile"
sudo mkdir -p /Volumes/files
sudo mount -o locallocks "$url" /Volumes/files

sudo cp "/Volumes/files/$targetFile" /tmp
sudo umount /Volumes/files
cd /tmp
VerifyHash "$targetFile" "$expectedHash"
sudo hdiutil attach "/tmp/$targetFile"

echo Installing JDK
cd /Volumes/JDK\ ${version} && sudo installer -package JDK\ ${version}.pkg -target /

echo "Unmounting $targetFile"
sudo hdiutil unmount /Volumes/JDK\ ${version} -force

echo "Disable auto update"
sudo defaults write /Library/Preferences/com.oracle.java.Java-Updater JavaAutoUpdateEnabled -bool false

echo "JDK Version = ${version}" >> ~/versions.txt
