#!/usr/bin/env bash
# Copyright (C) 2016 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs the minimum supported CMake to build Qt

# shellcheck source=../unix/InstallFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../unix/InstallFromCompressedFileFromURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

majorminorversion="3.16"
version="3.16.8"
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/cmake/cmake-$version-Linux-x86_64.tar.gz"
AltUrl="https://cmake.org/files/v$majorminorversion/cmake-$version-Linux-x86_64.tar.gz"
SHA1="a4d2f96f475ccc8e1ae1d97cf6c8ce39abaa9d7c"
targetFolder="/opt/cmake-$version"
appPrefix="cmake-$version-Linux-x86_64"

InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$targetFolder" "$appPrefix"

SetEnvVar "CMAKE_MIN_SUPPORTED_BIN_PATH" "$targetFolder/bin"

echo "CMake Min Supported = $version" >> ~/versions.txt

