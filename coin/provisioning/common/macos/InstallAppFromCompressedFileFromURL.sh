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
