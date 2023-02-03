#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2022 The Qt Company Ltd.
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

set -e

SSL_VER=$1
PACK_TYPE=$2
PROVISIONING_DIR="$(dirname "$0")/../../"
. "$PROVISIONING_DIR"/common/unix/common.sourced.sh
. "$PROVISIONING_DIR"/common/unix/DownloadURL.sh


localRepo=http://ci-files01-hki.intra.qt.io/input/docker
upstreamRepo=http://install.mimer.com/qt
if [ "$SSL_VER" = "openssl-3" ]; then
    if [ "$PACK_TYPE" = "rpm" ]; then
        packageFile=mimersqlsrv-11.0.x86_64-openssl3.rpm
        sha=5f21d440a12cddcc786ddff3a136bef821f1bf64
    else
        packageFile=mimersqlsrv_11.0_amd64-openssl3.deb
        sha=3239b593724c564862d3bbfb70fed16909a93959
    fi
else
    if [ "$PACK_TYPE" = "rpm" ]; then
        packageFile=mimersqlsrv-11.0.x86_64-openssl1.rpm
        sha=34533347424ba540b36d0a6ae2f416b901d8bafb
    else
        packageFile=mimersqlsrv_11.0_amd64-openssl1.deb
        sha=f4ac939a190ef048150b06cecc7a392386b6e132
    fi
fi
DownloadURL  $localRepo/$packageFile $upstreamRepo/$packageFile $sha /tmp/$packageFile

if [ "$PACK_TYPE" = "rpm" ]; then
    sudo rpm -U  /tmp/$packageFile
else
    sudo apt-get -y install /tmp/$packageFile
fi
rm -f /tmp/$packageFile
