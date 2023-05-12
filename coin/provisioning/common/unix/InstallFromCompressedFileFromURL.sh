#!/usr/bin/env bash
# Copyright (C) 2018 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# shellcheck source=DownloadURL.sh
source "${BASH_SOURCE%/*}/DownloadURL.sh"

function InstallFromCompressedFileFromURL {
    url=$1
    url_alt=$2
    expectedSha1=$3
    installDirectory=$4
    appPrefix=$5

    basefilename=${url##*/}
    extension=${basefilename##*.}
    filename=${basefilename%.*}
    if [ "$extension" == "gz" ] && [ "${filename##*.}" == "tar" ]; then
        extension="tar.gz"
    fi
    echo "Extension for file: $extension"
    echo "Creating temporary file and directory"
    targetFile=$(mktemp "$TMPDIR$(uuidgen)XXXXX.$extension")
    targetDirectory=$(mktemp -d)
    DownloadURL "$url" "$url_alt" "$expectedSha1" "$targetFile"
    echo "Uncompress $targetFile"
    case $extension in
        "tar.gz")
            tar -xzf "$targetFile" --directory "$targetDirectory"
        ;;
        "zip")
            unzip "$targetFile" -d "$targetDirectory"
        ;;
        "xz")
            tar -xf "$targetFile" --directory "$targetDirectory"
        ;;
        "tbz2")
            tar -xjf "$targetFile" --directory "$targetDirectory"
        ;;
        *)
            exit 1
        ;;
    esac
    echo "Moving app to $installDirectory"
    sudo mkdir -p "$installDirectory"
    sudo mv "$targetDirectory/$appPrefix/"* "$installDirectory"
    echo "Removing file '$targetFile'"
    rm "$targetFile"
    echo "Removing directory '$targetDirectory'"
    rm -rf "$targetDirectory"
}

