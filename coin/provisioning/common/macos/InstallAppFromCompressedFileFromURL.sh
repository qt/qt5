#!/usr/bin/env bash
# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script receives URLs to a compressed file. It then downloads it,
# uncompresses it and installs it by default
# to /Applications/. This can be overridden by a target parameter.

set -ex

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"

function InstallAppFromCompressedFileFromURL {
    url=$1
    url_alt=$2
    expectedSha1=$3
    appPrefix=$4
    target=$5

    if [ "" == "$target" ]; then
        target="/Applications/"
    fi

    basefilename=${url##*/}
    extension=${basefilename##*.}
    filename=${basefilename%.*}
    if [ "$extension" == "gz" ] && [ "${filename##*.}" == "tar" ]; then
        extension="tar.gz"
    fi

    echo "Extension for file: $extension"
    echo "Creating temporary file and directory"
    targetFile=$(mktemp "$TMPDIR$(uuidgen).$extension")
    # macOS 10.10 mktemp does require prefix
    if [[ $OSTYPE == "darwin14" ]]; then
        targetDirectory=$(mktemp -d -t '10.10')
    else
        targetDirectory=$(mktemp -d)
    fi
    (DownloadURL "$url" "$url_alt" "$expectedSha1" "$targetFile")
    echo "Uncompress $targetFile"
    case $extension in
        "tar.gz")
            tar -xzf "$targetFile" --directory "$targetDirectory"
        ;;
        "zip")
            unzip -q "$targetFile" -d "$targetDirectory"
        ;;
        *)
            exit 1
        ;;
    esac
    echo "Moving app to '$target'"
    sudo mv "$targetDirectory/$appPrefix/"* "$target"
    echo "Removing file '$targetFile'"
    rm "$targetFile"
    echo "Removing directory '$targetDirectory'"
    rm -rf "$targetDirectory"
}
