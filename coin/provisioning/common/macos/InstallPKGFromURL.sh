#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
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

set -ex

function InstallPKGFromURL {
    url=$1
    url_alt=$2
    expectedSha1=$3
    targetDirectory=$4

    echo "Creating temporary file"
    package_basename=$(echo "$url" | sed 's|^.*/||')
    tmpdir=$(mktemp -d)
    targetFile="$tmpdir/$package_basename"
    echo "Downloading PKG from primary URL '$url'"
    curl --fail -L --retry 5 --retry-delay 5 -o "$targetFile" "$url" || (
        echo "Failed to download '$url' multiple times"
        echo "Downloading PKG from alternative URL '$url_alt'"
        curl --fail -L --retry 5 --retry-delay 5 -o "$targetFile" "$url_alt"
    )
    echo "Checking SHA1 on PKG '$targetFile'"
    echo "$expectedSha1 *$targetFile" > "$targetFile".sha1
    /usr/bin/shasum --check "$targetFile".sha1
    echo "Run installer on PKG"
    sudo installer -package "$targetFile" -target "$targetDirectory"

    rm -f  "$targetFile".sha1
    rm -f  "$targetFile"
    rmdir  "$tmpdir"
}
