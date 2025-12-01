#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

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

    if ! [[ $version =~ ^[0-9] ]]; then
        echo "Error: version input must start with a digit"
        exit 1
    fi

    echo "Uncompressing and installing '$sourceFile'"
    if [[ $sourceFile =~ tar ]]; then
        cd /Applications/ && sudo tar -zxf "$sourceFile"
    elif [[ $sourceFile =~ "xip" ]]; then
        if [[ $sourceFile =~ "http" ]]; then
            Download "$sourceFile" "/Applications/Xcode_$version.xip"
            cd /Applications/ && xip -x "Xcode_$version.xip"
        else
            cd /Applications/ && xip -x "$sourceFile"
        fi
    else
        xzcat < "$sourceFile" | (cd /Applications/ && sudo cpio -dmi)
    fi

    echo "Versioning application bundle"
    majorVersion="${version%%[^0-9]*}"
    versionedAppBundle="/Applications/Xcode${majorVersion}.app"
    sudo mv /Applications/Xcode*.app "${versionedAppBundle}"

    echo "Selecting Xcode"
    sudo xcode-select --switch "${versionedAppBundle}"

    echo "Accept license"
    sudo xcodebuild -license accept

    echo "Install packages"
    sudo xcodebuild -runFirstLaunch

    # Metal toolchain not included by default in Xcode 26
    if ((majorVersion >= 26)); then
        xcodebuild -downloadComponent MetalToolchain
    fi

    echo "Enabling developer mode, so that using lldb does not require interactive password entry"
    sudo /usr/sbin/DevToolsSecurity -enable

    echo "Xcode = $version" >> ~/versions.txt
}
