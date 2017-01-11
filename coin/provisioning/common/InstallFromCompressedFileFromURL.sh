#!/bin/bash

#############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
## Contact: http://www.qt.io/licensing/
##
## This file is part of the test suite of the Qt Toolkit.
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

# shellcheck source=try_catch.sh
source "${BASH_SOURCE%/*}/try_catch.sh"
# shellcheck source=DownloadURL.sh
source "${BASH_SOURCE%/*}/DownloadURL.sh"

ExceptionCreateTmpFile=100
ExceptionCreateTmpDirectory=101
ExceptionUncompress=102
ExceptionMoveApp=103
ExceptionDeleteTmpFile=104
ExceptionRemoveTmpDirectory=105
ExceptionUnknownFormat=106


function InstallFromCompressedFileFromURL {
    url=$1
    url_alt=$2
    expectedSha1=$3
    installDirectory=$4
    appPrefix=$5

    try
    (
        basefilename=${url##*/}
        extension=${basefilename##*.}
        filename=${basefilename%.*}
        if [ "$extension" == "gz" ] && [ "${filename##*.}" == "tar" ]; then
            extension="tar.gz"
        fi
        echo "Extension for file: $extension"
        echo "Creating temporary file and directory"
        targetFile=$(mktemp "$TMPDIR$(uuidgen)XXXXX.$extension") || throw $ExceptionCreateTmpFile
        targetDirectory=$(mktemp -d) || throw $ExceptionCreateTmpDirectory
        DownloadURL "$url" "$url_alt" "$expectedSha1" "$targetFile"
        echo "Uncompress $targetFile"
        case $extension in
            "tar.gz")
                tar -xzf "$targetFile" --directory "$targetDirectory" || throw $ExceptionUncompress
            ;;
            "zip")
                unzip "$targetFile" -d "$targetDirectory" || throw $ExceptionUncompress
            ;;
            *)
                throw $ExceptionUnknownFormat
            ;;
        esac
        echo "Moving app to $installDirectory"
        sudo mkdir "$installDirectory"
        sudo mv "$targetDirectory/$appPrefix/"* "$installDirectory" || throw $ExceptionMoveApp
        echo "Removing file '$targetFile'"
        rm "$targetFile" || throw $ExceptionDeleteTmpFile
        echo "Removing directory '$targetDirectory'"
        rm -rf "$targetDirectory" || throw $ExceptionRemoveTmpDirectory
    )

    catch || {
        case $ex_code in
            $ExceptionCreateTmpFile)
                echo "Failed to create temporary file"
                exit 1;
            ;;
            $ExceptionUncompress)
                echo "Failed extracting compressed file."
                exit 1;
            ;;
            $ExceptionMoveApp)
                echo "Failed moving app to target location."
                exit 1;
            ;;
            $ExceptionDeleteTmpFile)
                echo "Failed deleting temporary file."
                exit 1;
            ;;
            $ExceptionRemoveTmpDirectory)
                echo "Failed deleting temporary file."
                exit 1;
            ;;
            $ExceptionUnknownFormat)
                echo "Unknown file format."
                exit 1;
            ;;
        esac
    }
}

