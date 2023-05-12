#!/usr/bin/env bash
# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs FBX SDK

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

set -e
tarballName="fbx20161_2_fbxsdk_linux.tar.gz"
targetFolder="/opt/fbx"
cachedUrl="http://ci-files01-hki.ci.qt.io/input/fbx/$tarballName"
officialUrl="http://download.autodesk.com/us/fbx_release_older/2016.1.2/$tarballName"
sha1="b0a08778de025e2c6e90d6fbdb6531f74a3da605"
tmpFolder="/tmp"
targetFile="$tmpFolder/$tarballName"
installer="$tmpFolder/fbx20161_2_fbxsdk_linux"

DownloadURL "$cachedUrl" "$officialUrl" "$sha1" "$targetFile"

sudo tar -C $tmpFolder -xf "$targetFile"
sudo mkdir -p $targetFolder
(echo "yes"; echo "n") | sudo "$installer" -w "$tmpFolder" "$targetFolder"

rm -rf "$targetFile"

# Set env variables
SetEnvVar "FBXSDK" "$targetFolder"

echo "FBX SDK = 2016.1.2" >> ~/versions.txt

