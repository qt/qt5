#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs JDK

set -ex

echo "Installing Java Development Kit"
version=11.0.12
targetFile=jdk-${version}_osx-x64_bin.dmg

url=ci-files01-hki.intra.qt.io:/hdd/www/input/mac
# url_alt=https://www.oracle.com/java/technologies/downloads/#java11-linux

echo "Mounting $targetFile"
sudo mkdir -p /Volumes/files
sudo mount -o locallocks "$url" /Volumes/files

sudo cp "/Volumes/files/$targetFile" /tmp
sudo umount /Volumes/files
sudo hdiutil attach "/tmp/$targetFile"

echo Installing JDK
cd /Volumes/JDK\ ${version} && sudo installer -package JDK\ ${version}.pkg -target /

echo "Unmounting $targetFile"
sudo hdiutil unmount /Volumes/JDK\ ${version} -force

echo "Disable auto update"
sudo defaults write /Library/Preferences/com.oracle.java.Java-Updater JavaAutoUpdateEnabled -bool false

echo "JDK Version = ${version}" >> ~/versions.txt
