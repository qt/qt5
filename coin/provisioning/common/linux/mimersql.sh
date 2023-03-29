#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -e

SSL_VER=$1
PACK_TYPE=$2
PROVISIONING_DIR="$(dirname "$0")/../../"
# shellcheck source=../unix/common.sourced.sh
source "${BASH_SOURCE%/*}/../unix/common.sourced.sh"
# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"


localRepo=http://ci-files01-hki.ci.qt.io/input/docker
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
