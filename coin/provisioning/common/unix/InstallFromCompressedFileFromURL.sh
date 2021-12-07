#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2018 The Qt Company Ltd.
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

