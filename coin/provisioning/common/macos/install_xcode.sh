#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2021 The Qt Company Ltd.
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

# shellcheck source=./../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"

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
    elif [[ $sourceFile =~ "xip" ]]; then
        if [[ $sourceFile =~ "http" ]]; then
            Download $sourceFile /Applications/Xcode_$version.xip
            cd /Applications/ && xip -x "Xcode_$version.xip"
        else
            cd /Applications/ && xip -x "$sourceFile"
        fi
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
