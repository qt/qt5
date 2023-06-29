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

# provides: python development libraries
# version: provided by default Linux distribution repository
# needed to build pyside

set -ex

PROVISIONING_DIR="$(dirname "$0")/../"
. "$PROVISIONING_DIR"/common/unix/common.sourced.sh
. "$PROVISIONING_DIR"/common/unix/DownloadURL.sh


# Selected installation instructions coming from:
# https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Python3/build_python3.sh
export PACKAGE_NAME="python"
python2Version="2.7.18"
python3Version="3.8.16"
python2Sha="678d4cf483a1c92efd347ee8e1e79326dc82810b"
python3Sha="d85dbb3774132473d8081dcb158f34a10ccad7a90b96c7e50ea4bb61f5ce4562"


function InstallPython {

    PACKAGE_VERSION=$1
    PACKAGE_SHA=$2

    $CMD_PKG_INSTALL  ncurses zlib-devel libffi-devel

    echo 'Configuration and Installation started'

    #Download Source code
    DownloadURL  \
        http://ci-files01-hki.intra.qt.io/input/python/Python-${PACKAGE_VERSION}.tar.xz  \
        https://www.python.org/ftp/${PACKAGE_NAME}/${PACKAGE_VERSION}/Python-${PACKAGE_VERSION}.tar.xz  \
        $PACKAGE_SHA
    tar -xf "Python-${PACKAGE_VERSION}.tar.xz"

    #Configure and Build
    cd "Python-${PACKAGE_VERSION}"
    ./configure --prefix=/usr/local --exec-prefix=/usr/local
    make
    sudo make install

    echo 'Installed python successfully'

    #Cleanup
    cd -
    rm "Python-${PACKAGE_VERSION}.tar.xz"

    #Verify python installation
    export PATH="/usr/local/bin:${PATH}"
    if command -V "$PACKAGE_NAME"${PACKAGE_VERSION:0:1} >/dev/null
    then
        printf -- "%s installation completed. Please check the Usage to start the service.\n" "$PACKAGE_NAME"
    else
        printf -- "Error while installing %s, exiting with 127 \n" "$PACKAGE_NAME"
        exit 127
    fi


}

InstallPython "$python2Version" "$python2Sha"
InstallPython "$python3Version" "$python3Sha"

python3 --version | fgrep "$python3Version"

pip3 install --user wheel
pip3 install --user virtualenv

# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"
SetEnvVar "PYTHON3_PATH" "/usr/local/bin"
