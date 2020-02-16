#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2018 The Qt Company Ltd.
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

# provides: python development libraries
# version: provided by default Linux distribution repository
# needed to build pyside

set -ex

PROVISIONING_DIR="$(dirname "$0")/../"
. "$PROVISIONING_DIR"/common/unix/common.sourced.sh
. "$PROVISIONING_DIR"/common/unix/DownloadURL.sh


# Python 2
$CMD_PKG_INSTALL python-devel

# Selected installation instructions coming from:
# https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/Python3/build_python3.sh
export PACKAGE_NAME="python"
export PACKAGE_VERSION="3.7.6"
export PACKAGE_SHA=55a2cce72049f0794e9a11a84862e9039af9183603b78bc60d89539f82cf533f
(

    $CMD_PKG_INSTALL  ncurses zlib-devel libffi-devel libopenssl-devel

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
)


python3 --version | fgrep "$PACKAGE_VERSION"

pip3 install --user wheel
pip3 install --user virtualenv

# Install all needed packages in a special wheel cache directory
pip3 wheel --wheel-dir "$HOME/python3-wheels" -r "${BASH_SOURCE%/*}/../common/shared/requirements.txt"

# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"
SetEnvVar "PYTHON3_WHEEL_CACHE" "$HOME/python3-wheels"
