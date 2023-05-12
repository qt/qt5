#!/usr/bin/env bash
# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
set -ex

# Command line tools is need by homebrew

function InstallCommandLineTools {
    url=$1
    url_alt=$2
    expectedSha1=$3
    packageName=$4
    version=$5

    DownloadURL "$url" "$url_alt" "$expectedSha1" "/tmp/$packageName"
    echo "Mounting $packageName"
    hdiutil attach "/tmp/$packageName"
    cd "/Volumes/Command Line Developer Tools"
    echo "Installing"
    sudo installer -pkg ./*.pkg -target / -allowUntrusted
    cd /
    # Let's fait for 5 second before unmounting. Sometimes resource is busy and cant be unmounted
    sleep 3
    echo "Unmounting"
    umount /Volumes/Command\ Line\ Developer\ Tools/
    echo "Removing $packageName"
    rm "/tmp/$packageName"

    echo "Command Line Tools = $version" >> ~/versions.txt
}
