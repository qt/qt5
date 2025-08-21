#!/usr/bin/env bash
# Copyright (C) 2017 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# PySide versions following 5.6 use a C++ parser based on Clang (http://clang.org/).
# The Clang library (C-bindings), version 3.9 or higher is required for building.

# This same script is used to provision libclang to Linux and macOS.
# In case of Linux, we expect to get the values as args
set -e

# shellcheck source=./check_and_set_proxy.sh
source "${BASH_SOURCE%/*}/check_and_set_proxy.sh"
# shellcheck source=./SetEnvVar.sh
source "${BASH_SOURCE%/*}/SetEnvVar.sh"
# shellcheck source=./DownloadURL.sh
source "${BASH_SOURCE%/*}/DownloadURL.sh"

libclang_version=10.0

if uname -a |grep -q Darwin; then
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/libclang-release_${version//\./}-based-mac.7z"
    sha1="0fe1fa50b1b469d2c05acc3a3468bc93a66f1e5a"
    url_cached="http://ci-files01-hki.ci.qt.io/input/libclang/dynamic/libclang-release_${version//\./}-based-mac.7z"
elif test -f /etc/redhat-release || /etc/centos-release; then
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/libclang-release_${version//\./}-based-linux-Rhel7.6-gcc5.3-x86_64.7z"
    sha1="1d2e265502fc0832a854f989d757105833fbd179"
    url_cached="http://ci-files01-hki.ci.qt.io/input/libclang/dynamic/libclang-release_${version//\./}-based-linux-Rhel7.6-gcc5.3-x86_64.7z"
else
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/dynamic/libclang-release_${version//\./}-based-linux-Ubuntu18.04-gcc9.2-x86_64.7z"
    sha1="c1580acb3a82e193acf86f18afb52427c5e67de8"
    url_cached="http://ci-files01-hki.ci.qt.io/input/libclang/libclang-release_${version//\./}-based-linux-Ubuntu18.04-gcc9.2-x86_64.7z"
fi

zip="/tmp/libclang.7z"
destination="/usr/local/libclang-dynlibs-$version"

DownloadURL "$url_cached" "$url" "$sha1" "$zip"
if command -v 7zr &> /dev/null; then
    sudo 7zr x $zip -o/usr/local/
else
    sudo 7z x $zip -o/usr/local/
fi
sudo mv /usr/local/libclang "$destination"
rm -rf $zip


SetEnvVar "LLVM_DYNAMIC_LIBS_100" "$destination"
echo "libClang for QtForPython= $version" >> ~/versions.txt
