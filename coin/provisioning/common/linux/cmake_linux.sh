#!/usr/bin/env bash
# Copyright (C) 2016 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs CMake

# CMake is needed for autotests that verify that Qt can be built with CMake

# shellcheck source=../unix/InstallFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../unix/InstallFromCompressedFileFromURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

majorminorversion="4.3"
version="4.3.2"

uname_m="$(uname -m)"
case "$uname_m" in
    x86_64|amd64)
        SHA1="736c0722ed8393b3eb74fd573f6c9c245770206a"
        arch="x86_64"
        ;;
    arm64|aarch64)
        SHA1="a173eb910c808f561422feb45fe1fe57c3e346fa"
        arch="aarch64"
        ;;
    *) fatal "Unknown architecture in uname: $uname_m" 43 ;;
esac

PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/cmake/cmake-$version-linux-$arch.tar.gz"
AltUrl="https://cmake.org/files/v$majorminorversion/cmake-$version-linux-$arch.tar.gz"
targetFolder="/opt/cmake-$version"
appPrefix="cmake-$version-linux-$arch"

InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$targetFolder" "$appPrefix"

SetEnvVar "PATH" "$targetFolder/bin:\$PATH"

echo "CMake = $version" >> ~/versions.txt

