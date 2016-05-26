#!/bin/env bash

#############################################################################
##
## Copyright (C) 2016 The Qt Company Ltd.
## Contact: http://www.qt.io/licensing/
##
## This file is part of the test suite of the Qt Toolkit.
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

# Patch QNX SDK due to issues in the standard library.
# The patches are available here:
# http://www.qnx.com/download/feature.html?programid=27555
# A copy of the patch must be in the root of the Coin path in
# provisioning/qnx/patch-660-4367-RS6069_cpp-headers.zip

set -e
sha1="57a11ffe4434ad567b3c36f7b828dbb468a9e565"

function InstallZipPackageFromURL {
    url=$1
    expectedSha1=$2
    targetDirectory=$3

    targetFile=`mktemp` || echo "Failed to create temporary file"
    wget --tries=5 --waitretry=5 --output-document=$targetFile $url || echo "Failed to download '$url' multiple times"
    echo "$expectedSha1  $targetFile" | sha1sum --check || echo "Failed to check sha1sum"

    tempDir=`mktemp -d` || echo "Failed to create temporary directory"
    /usr/bin/unzip -o -d $tempDir $targetFile || echo "Failed to unzip $url archive"
    trap "sudo rm -fr $targetFile $tempDir" EXIT

    sudo cp -rafv $tempDir/patches/660-4367/target/* /opt/qnx660/target/
}

echo "Patching QNX"

baseBinaryPackageURL="http://${COIN_WEBSERVER_ADDRESS}/coin/provisioning/qnx/patch-660-4367-RS6069_cpp-headers.zip"
InstallZipPackageFromURL $baseBinaryPackageURL $sha1 "/opt/qnx660/target/"
