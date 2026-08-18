#!/usr/bin/env bash
# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs the CI network tester
set -ex
source "${BASH_SOURCE%/*}/../unix/InstallFromCompressedFileFromURL.sh"

if [ -z ${COIN_UNIQUE_JOB_ID+x} ]; then
    echo "This script only runs in a CI envrironment. Exiting."
    exit 0;
fi

PREFIX="opt"
ROOT="/${PREFIX}"
APPNAME="CiNetworkTest"
EXECPATH="${ROOT}/${APPNAME}/bin"
EXEC="${EXECPATH}/${APPNAME}"
URL="https://ci-files01-hki.ci.qt.io/input/networktestapp"
TARBALL="CiNetworkTest-rhel-linux-x86_64-v1.2.tgz"
sha256="2be05baebf48ff29ebcd06a0761b2a3d92ae5a66f78d0cd953513d8271eb7f83"
SOURCE="$URL/$TARBALL"
InstallFromCompressedFileFromURL "$SOURCE" "" "$sha256" "$ROOT" "$PREFIX"

# Ubuntu installs ICU in opt
if grep -q "Ubuntu" /etc/os-release; then
    export LD_LIBRARY_PATH="/opt/icu/lib64"
fi

if [ -e "$EXEC" ]; then
    $EXEC $1 && exit 0;
else
    echo "Installation unsuccessful. Content of ${ROOT}:"
    echo "-----------------------------------------------"
    ls -l $ROOT
    echo "-----------------------------------------------"
fi
exit 1;
