#!/usr/bin/env bash
#############################################################################
##
## Copyright (C) 2018 The Qt Company Ltd.
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

# This script installs FBX SDK

set -ex

# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

version="2016.1.2"
fileName="fbx20161_2_fbxsdk_clang_mac.pkg_nospace.tgz"
cachedUrl="/net/ci-files01-hki.intra.qt.io/hdd/www/input/fbx/$fileName"
# officialUrl="http://download.autodesk.com/us/fbx_release_older/$version/fbx20161_2_fbxsdk_clang_mac.pkg.tgz"
targetFolder="/tmp"

echo "Extracting '$cachedUrl'"
tar -xzf "$cachedUrl" -C "$targetFolder"

rm -rf "$targetFolder/$fileName"
echo "Copying preinstalled FBX SDK to Applications"
sudo cp -r "$targetFolder/Autodesk" /Applications

# Set env variables
SetEnvVar "FBXSDK" "/Applications/Autodesk/FBXSDK/2016.1.2/"

echo "FBX SDK = 2016.1.2" >> ~/versions.txt

