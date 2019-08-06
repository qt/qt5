#!/usr/bin/env bash

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

# This script install OpenSSL

set -ex

# shellcheck source=../unix/InstallFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../unix/InstallFromCompressedFileFromURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

opensslVersion="1.1.1a"
opensslFile="openssl-$opensslVersion.tar.gz"
opensslDlUrl="http://ci-files01-hki.intra.qt.io/input/openssl/$opensslFile"
opensslAltDlUrl="https://www.openssl.org/source/$opensslFile"
opensslSha1="8fae27b4f34445a5500c9dc50ae66b4d6472ce29"

# Below target location has been hard coded into Coin.
# QTQAINFRA-1195
openssl_install_dir=/usr/local/openssl-$opensslVersion
opensslTargetLocation="/usr/local/opt/openssl"

InstallFromCompressedFileFromURL "$opensslDlUrl" "$opensslAltDlUrl" "$opensslSha1" "/tmp/openssl-$opensslVersion" "openssl-$opensslVersion"
cd "/tmp/openssl-$opensslVersion"
sudo ./Configure --prefix=$openssl_install_dir shared no-ssl3-method enable-ec_nistp_64_gcc_128 darwin64-x86_64-cc "-Wa,--noexecstack"

sudo make install_sw install_ssldirs

path=$(echo "$opensslTargetLocation" | sed -E 's/(.*)\/.*$/\1/')
sudo mkdir -p "$path"
sudo ln -s $openssl_install_dir $opensslTargetLocation

SetEnvVar "PATH" "\"$opensslTargetLocation/bin:\$PATH\""
SetEnvVar "MANPATH" "\"$opensslTargetLocation/share/man:\$MANPATH\""

SetEnvVar "OPENSSL_DIR" "\"$openssl_install_dir\""
SetEnvVar "OPENSSL_INCLUDE" "\"$openssl_install_dir/include\""
SetEnvVar "OPENSSL_LIB" "\"$openssl_install_dir/lib\""

security find-certificate -a -p /Library/Keychains/System.keychain | sudo tee -a $opensslTargetLocation/ssl/cert.pem > /dev/null
security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain | sudo tee -a $opensslTargetLocation/ssl/cert.pem > /dev/null

sudo rm -rf /tmp/openssl-$opensslVersion

echo "OpenSSL = $opensslVersion" >> ~/versions.txt
