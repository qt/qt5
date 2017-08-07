#!/bin/env bash

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

# This script install OpenSSL from sources.
# Requires GCC and Perl to be in PATH.

source "${BASH_SOURCE%/*}/try_catch.sh"
source "${BASH_SOURCE%/*}/DownloadURL.sh"

version="1.0.2g"
officialUrl="https://www.openssl.org/source/openssl-$version.tar.gz"
cachedUrl="http://ci-files01-hki.intra.qt.io/input/openssl/openssl-$version.tar.gz"
targetFile="/tmp/openssl-$version.tar.gz"
installFolder="/home/qt/"
sha="36af23887402a5ea4ebef91df8e61654906f58f2"
# Until every VM doing Linux Android builds have provisioned the env variable
# OPENSSL_ANDROID_HOME, we can't change the hard coded path that's currently in Coin.
# QTQAINFRA-1436
opensslHome="${installFolder}openssl-1.0.2"

ExceptionDownload=99
ExceptionTar=100
ExceptionConfig=101

try
(
    (DownloadURL "$cachedUrl" "$officialUrl" "$sha" "$targetFile") || throw $ExceptionDownload

    tar -xzf "$targetFile" -C "$installFolder" || throw $ExceptionTar
    # This rename should be removed once hard coded path from Coin is fixed. (QTQAINFRA-1436)
    mv "${opensslHome}g" "${opensslHome}"
    pushd "$opensslHome"
    perl Configure shared android || throw $ExceptionConfig

    echo "export OPENSSL_ANDROID_HOME=$opensslHome" >> ~/.bashrc
    echo "OpenSSL for Android = $version" >> ~/versions.txt
)
catch || {
    case $ex_code in
        $ExceptionDownload)
            exit 1;
        ;;
        $ExceptionTar)
            echo "Failed to extract $targetFile"
            exit 1;
        ;;
        $ExceptionConfig)
            echo "Failed to run 'config'."
            exit 1;
        ;;
    esac

}
