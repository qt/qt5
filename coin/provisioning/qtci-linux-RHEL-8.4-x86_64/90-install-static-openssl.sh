#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# This is required to allow static linking of ifw
os="$1"
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"
# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"

targetFile="/tmp/openssl-$version.tar.gz"
downloadFile="http://ci-files01-hki.intra.qt.io/input/openssl/openssl-3.0.7-static-only.tar.gz"
sha="82376a9e2440a47a83eb861cbf9363b28630a120"
DownloadURL "$downloadFile" "$downloadFile" "$sha" "$targetFile"

cd $HOME
tar -xzf "$targetFile"
SetEnvVar "STATIC_OPENSSL_HOME" "$HOME/static-openssl"
