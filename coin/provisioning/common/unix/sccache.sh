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

source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"
## comment fo changin patchset..coin privision issue

function installSccache {
    targetArch=$1
    targetVersion=$2
    sha1=$3
    targetFile=sccache-$targetVersion-$targetArch.tar.gz
    primaryUrl=http://ci-files01-hki.intra.qt.io/input/sccache/$targetFile
    cacheUrl=https://github.com/mozilla/sccache/releases/download/$targetVersion/$targetFile
    DownloadURL "$primaryUrl" "$cacheUrl" "$sha1" "$targetFile"

    sudo mkdir -p /usr/local/sccache
    sudo tar -C /usr/local/sccache -x -z --totals --strip-components=1 --file="$targetFile"

    # add sccache __before__ the real compiler
    SetEnvVar "PATH" "/usr/local/sccache:\$PATH"

    # disable sccache server from shutting down after being idle
    SetEnvVar "SCCACHE_IDLE_TIMEOUT" "0"

    # copy sccache wrapper and place as a first in PATH
    mkdir -p $HOME/sccache_wrapper
    cp ${BASH_SOURCE%/*}/sccache_wrapper $HOME/sccache_wrapper/sccache
    chmod 755 $HOME/sccache_wrapper/sccache
    SetEnvVar "PATH" "$HOME/sccache_wrapper:\$PATH"

}
