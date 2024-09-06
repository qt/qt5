#!/usr/bin/env bash
# Copyright (C) 2018 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"
## comment fo changin patchset..coin privision issue

function installSccache {
    targetArch=$1
    targetVersion=$2
    sha1=$3
    targetFile=sccache-$targetVersion-$targetArch.tar.gz
    primaryUrl=http://ci-files01-hki.ci.qt.io/input/sccache/$targetFile
    cacheUrl=https://github.com/mozilla/sccache/releases/download/$targetVersion/$targetFile
    DownloadURL "$primaryUrl" "$cacheUrl" "$sha1" "$targetFile"

    sudo mkdir -p /usr/local/sccache
    sudo tar -C /usr/local/sccache -x -z --totals --strip-components=1 --file="$targetFile"
    sudo chmod +x /usr/local/sccache/sccache

    # add sccache __before__ the real compiler
    SetEnvVar "PATH" "/usr/local/sccache:\$PATH"

    # disable sccache server from shutting down after being idle
    SetEnvVar "SCCACHE_IDLE_TIMEOUT" "0"

    # copy sccache wrapper and place as a first in PATH
    mkdir -p "$HOME/sccache_wrapper"
    cp "${BASH_SOURCE%/*}/sccache_wrapper" "$HOME/sccache_wrapper/sccache"
    chmod 755 "$HOME/sccache_wrapper/sccache"
    SetEnvVar "PATH" "$HOME/sccache_wrapper:\$PATH"

    # Prevents some random network I/O errors from failing compilation
    # Does not seem to affect much though
    SetEnvVar "SCCACHE_IGNORE_SERVER_IO_ERROR" "1"
}
