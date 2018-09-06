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

# This script installs Xcode
# Prerequisites: Have Xcode prefetched to local cache as xz compressed.
# This can be achieved by fetching Xcode_8.xip from Apple Store.
# Uncompress it with 'xar -xf Xcode_8.xip'
# Then get https://gist.githubusercontent.com/pudquick/ff412bcb29c9c1fa4b8d/raw/24b25538ea8df8d0634a2a6189aa581ccc6a5b4b/parse_pbzx2.py
# with which you can run 'python parse_pbzx2.py Content'.
# This will give you a file called "Content.part00.cpio.xz" that
# can be renamed to Xcode_8.xz for this script.



function InstallXCode() {
    sourceFile=$1
    version=$2

    echo "Uncompressing and installing '$sourceFile'"
    if [[ $sourceFile =~ tar ]]; then
        cd /Applications/ && sudo tar -zxf "$sourceFile"
    else
        xzcat < "$sourceFile" | (cd /Applications/ && sudo cpio -dmi)
    fi

    echo "Versioning application bundle"
    majorVersion=$(echo $version | cut -d '.' -f 1)
    versionedAppBundle="/Applications/Xcode${majorVersion}.app"
    sudo mv /Applications/Xcode.app ${versionedAppBundle}

    echo "Selecting Xcode"
    sudo xcode-select --switch ${versionedAppBundle}

    echo "Accept license"
    sudo xcodebuild -license accept

    echo "Install packages"
    # -runFirstLaunch is valid in 9.x
    sudo xcodebuild -runFirstLaunch || true

    echo "Enabling developer mode, so that using lldb does not require interactive password entry"
    sudo /usr/sbin/DevToolsSecurity -enable

    echo "Xcode = $version" >> ~/versions.txt
}
