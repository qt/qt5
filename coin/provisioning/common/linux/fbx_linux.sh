#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
## Contact: https://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see https://www.qt.io/terms-conditions. For further
## information use the contact form at https://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 3 as published by the Free Software
## Foundation and appearing in the file LICENSE.LGPL3 included in the
## packaging of this file. Please review the following information to
## ensure the GNU Lesser General Public License version 3 requirements
## will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 2.0 or (at your option) the GNU General
## Public license version 3 or any later version approved by the KDE Free
## Qt Foundation. The licenses are as published by the Free Software
## Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
## included in the packaging of this file. Please review the following
## information to ensure the GNU General Public License requirements will
## be met: https://www.gnu.org/licenses/gpl-2.0.html and
## https://www.gnu.org/licenses/gpl-3.0.html.
##
## $QT_END_LICENSE$
##
#############################################################################

# This script installs FBX SDK

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

set -e
tarballName="fbx20161_2_fbxsdk_linux.tar.gz"
targetFolder="/opt/fbx"
cachedUrl="http://ci-files01-hki.intra.qt.io/input/fbx/$tarballName"
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

