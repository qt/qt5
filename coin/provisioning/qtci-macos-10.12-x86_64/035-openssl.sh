#!/bin/bash

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

# This script install OpenSSL

# shellcheck source=../common/try_catch.sh
source "${BASH_SOURCE%/*}/../common/try_catch.sh"
# shellcheck source=../common/InstallFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../common/InstallFromCompressedFileFromURL.sh"

opensslVersion="1.0.2k"
opensslFile="openssl-$opensslVersion.tar.gz"
opensslDlUrl="http://ci-files01-hki.ci.local/input/openssl/$opensslFile"
opensslAltDlUrl="https://www.openssl.org/source/$opensslFile"
opensslSha1="5f26a624479c51847ebd2f22bb9f84b3b44dcb44"

# Below target location has been hard coded into Coin.
# QTQAINFRA-1195
opensslTargetLocation="/usr/local/opt/openssl"

ExceptionCD=100
ExceptionConfig=101
ExceptionMake=102
ExceptionInstall=103
ExceptionLN=104
ExceptionCertificate=105
ExceptionCleanup=106

try
(
    InstallFromCompressedFileFromURL "$opensslDlUrl" "$opensslAltDlUrl" "$opensslSha1" "/tmp/openssl-$opensslVersion" "openssl-$opensslVersion"
    cd "/tmp/openssl-$opensslVersion" || throw $ExceptionCD
    pwd
    sudo ./config --prefix=/usr/local/openssl-$opensslVersion || throw $ExceptionConfig
    echo "Running 'make' for OpenSSL"
    sudo make --silent > /tmp/openssl_make.log 2>&1 || throw $ExceptionMake
    echo "Running 'make install' for OpenSSL"
    sudo make --silent install > /tmp/openssl_make_install.log 2>&1 || throw $ExceptionInstall

    path=$(echo "$opensslTargetLocation" | sed -E 's/(.*)\/.*$/\1/')
    sudo mkdir -p "$path"
    sudo ln -s /usr/local/openssl-$opensslVersion $opensslTargetLocation || throw $ExceptionLN

    echo "export PATH=\"$opensslTargetLocation/bin:$PATH\"" >> ~/.bashrc
    echo "export MANPATH=\"$opensslTargetLocation/share/man:$MANPATH\"" >> ~/.bashrc

    security find-certificate -a -p /Library/Keychains/System.keychain | sudo tee -a $opensslTargetLocation/ssl/cert.pem || throw $ExceptionCertificate
    security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain | sudo tee -a $opensslTargetLocation/ssl/cert.pem || throw $ExceptionCertificate

    sudo rm -rf /tmp/openssl-$opensslVersion || throw $ExceptionCleanup

    echo "OpenSSL = $opensslVersion" >> ~/versions.txt
)
catch || {
    case $ex_code in
        $ExceptionCD)
            echo "Failed to change directory to /tmp/openssl-$opensslVersion."
            exit 1;
        ;;
        $ExceptionConfig)
            echo "Failed to run config for OpenSSL."
            exit 1;
        ;;
        $ExceptionMake)
            echo "Failed to run 'make' for OpenSSL."
            exit 1;
        ;;
        $ExceptionInstall)
            echo "Failed to run 'make install' for OpenSSL."
            exit 1;
        ;;
        $ExceptionLN)
            echo "Failed to create a soft link for OpenSSL."
            exit 1;
        ;;
        $ExceptionCertificate)
            echo "Failed to install Certificate for OpenSSL."
            exit 1;
        ;;
        $ExceptionCleanup)
            echo "Failed to clean up /tmp/openssl-$opensslVersion."
            exit 1;
        ;;
    esac
}
