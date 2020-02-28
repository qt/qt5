#!/bin/sh

#############################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
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


# A helper script used for downloading a file from a URL or an alternative
# URL. Also the SHA is checked for the file (SHA algorithm is autodetected
# based on the SHA length). Target filename should also be given.

############################ BOILERPLATE ###############################

command -v sha1sum   >/dev/null ||  sha1sum   () { shasum -a 1   "$@" ; }
command -v sha256sum >/dev/null ||  sha256sum () { shasum -a 256 "$@" ; }
command -v sha384sum >/dev/null ||  sha384sum () { shasum -a 384 "$@" ; }
command -v sha512sum >/dev/null ||  sha512sum () { shasum -a 512 "$@" ; }

########################################################################


Download () {
    url="$1"
    targetFile="$2"

    command -v curl >/dev/null  \
        && curl --fail -L --retry 5 --retry-delay 5 -o "$targetFile" "$url"  \
        || wget --tries 5 -O "$targetFile" "$url"
}

VerifyHash () {
    file=$1
    expectedHash=$2

    if [ ! -f "$file" ]
    then  return 2              # file does not exist
    fi


    hashLength="$(echo "$expectedHash" | wc -c | sed 's/ *//g')"
    # Use backticks because of bug with bash-3 (default on macOS),
    # caused when there are unbalanced parentheses inside $()
    # shellcheck disable=SC2006
    hash=`case "$hashLength" in
            41)  sha1sum    "$file"  ;;
            65)  sha256sum  "$file"  ;;
            97)  sha384sum  "$file"  ;;
            129) sha512sum  "$file"  ;;
            *) echo "FATAL! Unknown hash length:  $hashLength" 1>&2  &&  exit 1  ;;
        esac | cut -d ' ' -f 1`

    if [ ! "$expectedHash" = "$hash" ]
    then
        echo "FAIL! wrong file hash:  $file  $hash"  1>&2
        return 1
    fi
    echo "OK verified integrity of:  $file"
}

# Check if file already exists and is good, otherwise download it
DownloadURL () {
    url=$1
    url2=$2
    expectedHash=$3
    # Optional argument $4: destination filename
    if [ x"$4" = x ]
    then
        # defaults to the last component of $url
        targetFile=$(echo $url | sed 's|^.*/||')
    else
        targetFile=$4
    fi

    # If a non-empty file already exists
    if [ -s "$targetFile" ]
    then
        if   VerifyHash "$targetFile" "$expectedHash"
        then
            echo "Skipping download, found and validated existing file:  $targetFile"
            return
        else
            echo "WARNING: Non-empty but different file found at destination; will re-download and overwrite file:  $targetFile"
        fi
    fi

    echo "Downloading from primary URL:  $url"
    if  ! Download "$url" "$targetFile"
    then
        echo "FAIL! to download, trying alternative URL:  $url2"  1>&2
        if  ! Download "$url2" "$targetFile"
        then
            echo 'FAIL! to download even from alternative URL'  1>&2
            return 1
        fi
    fi
    VerifyHash "$targetFile" "$expectedHash"
}
