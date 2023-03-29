#!/usr/bin/env bash
# Copyright (C) 2018 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs FBX SDK

set -ex

# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

#version="2016.1.2"
fileName="fbx20161_2_fbxsdk_clang_mac.pkg_nospace.tgz"
cachedUrl="/net/ci-files01-hki.ci.qt.io/hdd/www/input/fbx/$fileName"
# officialUrl="http://download.autodesk.com/us/fbx_release_older/$version/fbx20161_2_fbxsdk_clang_mac.pkg.tgz"
targetFolder="/tmp"

echo "Extracting '$cachedUrl'"
tar -xzf "$cachedUrl" -C "$targetFolder"

rm -rf "${targetFolder:?}/${fileName}"
echo "Copying preinstalled FBX SDK to Applications"
sudo cp -r "$targetFolder/Autodesk" /Applications

# Set env variables
SetEnvVar "FBXSDK" "/Applications/Autodesk/FBXSDK/2016.1.2/"

echo "FBX SDK = 2016.1.2" >> ~/versions.txt

