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

# This script install OpenSSL

set -ex

# shellcheck source=../common/unix/InstallFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../common/unix/InstallFromCompressedFileFromURL.sh"
# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"

opensslVersion="1.0.2o"
opensslFile="openssl-$opensslVersion.tar.gz"
opensslDlUrl="http://ci-files01-hki.intra.qt.io/input/openssl/$opensslFile"
opensslAltDlUrl="https://www.openssl.org/source/$opensslFile"
opensslSha1="a47faaca57b47a0d9d5fb085545857cc92062691"

# Below target location has been hard coded into Coin.
# QTQAINFRA-1195
opensslTargetLocation="/usr/local/opt/openssl"

InstallFromCompressedFileFromURL "$opensslDlUrl" "$opensslAltDlUrl" "$opensslSha1" "/tmp/openssl-$opensslVersion" "openssl-$opensslVersion"
cd "/tmp/openssl-$opensslVersion"
pwd
sudo ./config --prefix=/usr/local/openssl-$opensslVersion
echo "Running 'make' for OpenSSL"
sudo make --silent > /tmp/openssl_make.log 2>&1
echo "Running 'make install' for OpenSSL"
sudo make --silent install > /tmp/openssl_make_install.log 2>&1

path=$(echo "$opensslTargetLocation" | sed -E 's/(.*)\/.*$/\1/')
sudo mkdir -p "$path"
sudo ln -s /usr/local/openssl-$opensslVersion $opensslTargetLocation

SetEnvVar "PATH" "\"$opensslTargetLocation/bin:\$PATH\""
SetEnvVar "MANPATH" "\"$opensslTargetLocation/share/man:\$MANPATH\""

security find-certificate -a -p /Library/Keychains/System.keychain | sudo tee -a $opensslTargetLocation/ssl/cert.pem
security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain | sudo tee -a $opensslTargetLocation/ssl/cert.pem

sudo rm -rf /tmp/openssl-$opensslVersion

echo "OpenSSL = $opensslVersion" >> ~/versions.txt
