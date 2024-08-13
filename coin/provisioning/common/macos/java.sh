#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs JDK

set -ex

source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"

echo "Installing Java Development Kit"
version=17.0.12
targetFile=jdk-${version}_macos-x64_bin.dmg
expectedHash="6fba2fbe5d181bd2ef7fd79e0335278c13f611cb"

url=ci-files01-hki.ci.qt.io:/hdd/www/input/mac
# url_alt=https://www.oracle.com/java/technologies/downloads/#jdk17-mac

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
