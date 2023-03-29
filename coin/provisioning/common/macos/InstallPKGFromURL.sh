#!/usr/bin/env bash
# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

function InstallPKGFromURL {
    url=$1
    url_alt=$2
    expectedSha1=$3
    targetDirectory=$4

    echo "Creating temporary file"
    package_basename="${url/*\//}"
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
