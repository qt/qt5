#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.
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

PROVISIONING_DIR="$(dirname "$0")/../../"
# shellcheck source=./common.sourced.sh
source "$PROVISIONING_DIR"/common/unix/common.sourced.sh

zswitch=$1 # Since 7z 25.01 multi-hop symbolic links are restricted with -snl switch levels
libclang_version="20.1.0"

if uname -a |grep -q Darwin; then
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-llvmorg-${version}-macos-universal.7z"
    url_cached="http://ci-files01-hki.ci.qt.io/input/libclang/qt/libclang-llvmorg-${version}-macos-universal.7z"
    sha1="a0061a2b7a7411323ae3d81fdb2071ad522ddd5f"
elif test -f /etc/redhat-release && grep "Red Hat" /etc/redhat-release | grep "9" ; then
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-llvmorg-${version}-linux-Rhel9.4-gcc11.4-x86_64.7z"
    url_cached="http://ci-files01-hki.ci.qt.io/input/libclang/qt/libclang-llvmorg-${version}-linux-Rhel9.4-gcc11.4-x86_64.7z"
    sha1="041036bb2b360c18448c993671507bbb16b9b76d"
elif test "$PROVISIONING_OS_ID" == "debian" && test "$PROVISIONING_ARCH" == "arm64" ; then
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-llvmorg-${version}-linux-Debian11.6-gcc10.0-arm64.7z"
    url_cached="http://ci-files01-hki.ci.qt.io/input/libclang/qt/libclang-llvmorg-${version}-linux-Debian11.6-gcc10.0-arm64.7z"
    sha1="ad3244f76cb5dab8e3d5dfe839e21a9bac3039e9"
elif test "$PROVISIONING_OS_ID" == "ubuntu" && test "$PROVISIONING_ARCH" == "arm64" ; then
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-llvmorg-${version}-linux-Ubuntu24.04-gcc11.2-arm64.7z"
    url_cached="http://ci-files01-hki.ci.qt.io/input/libclang/qt/libclang-llvmorg-${version}-linux-Ubuntu24.04-gcc11.2-arm64.7z"
    sha1="bde39a28872cc618983d231ffd1df2c104ff1992"
elif test "$PROVISIONING_OS_ID" == "ubuntu" && test "$PROVISIONING_ARCH" == "x86_64" ; then
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-llvmorg-${version}-linux-Ubuntu22.04-gcc11.2-x86_64.7z"
    url_cached="http://ci-files01-hki.ci.qt.io/input/libclang/qt/libclang-llvmorg-${version}-linux-Ubuntu22.04-gcc11.2-x86_64.7z"
    sha1="3f5e5214cf31adfb01be21fcf4f27b9adf8f13b0"
else
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-llvmorg-${version}-linux-Rhel8.10-gcc10.0-x86_64.7z"
    url_cached="http://ci-files01-hki.ci.qt.io/input/libclang/qt/libclang-llvmorg-${version}-linux-Rhel8.10-gcc10.0-x86_64.7z"
    sha1="1fdc23ae0fce48ed82508b1bad0c68d2e5a30c8b"
fi

zip="/tmp/libclang.7z"
destination="/usr/local/libclang-$version"

DownloadURL $url_cached $url $sha1 $zip
if command -v 7zr &> /dev/null; then
    sudo 7zr x $zip -o/usr/local/
else
    sudo 7z x $zswitch $zip -o/usr/local/
fi
sudo mv /usr/local/libclang "$destination"
rm -rf $zip


SetEnvVar "LLVM_INSTALL_DIR" "$destination"
echo "libClang = $version" >> ~/versions.txt
