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

libclang_version="17.0.6"

if uname -a |grep -q Darwin; then
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-release_${version}-based-mac.7z"
    url_cached="http://ci-files01-hki.ci.qt.io/input/libclang/qt/libclang-release_${version}-based-mac.7z"
    sha1="e8ecc2fb0d7d7a0f60a50379f16fbf3eef679d78"
elif test -f /etc/redhat-release && grep "Red Hat" /etc/redhat-release | grep "9" ; then
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-release_${version}-based-linux-Rhel9.2-gcc10.0-x86_64.7z"
    url_cached="http://ci-files01-hki.ci.qt.io/input/libclang/qt/libclang-release_${version}-based-linux-Rhel9.2-gcc10.0-x86_64.7z"
    sha1="102374379af906bd26085fcd18047cac4d0fb7bf"
elif test "$PROVISIONING_OS_ID" == "ubuntu" ; then
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-release_${version}-based-linux-Ubuntu22.04-gcc11.2-x86_64.7z"
    url_cached="http://ci-files01-hki.ci.qt.io/input/libclang/qt/libclang-release_${version}-based-linux-Ubuntu22.04-gcc11.2-x86_64.7z"
    sha1="4a793c9da9a02bd23c163c74dbc5565164a00c3f"
elif test "$PROVISIONING_OS_ID" == "debian" && test "$PROVISIONING_ARCH" == "arm64" ; then
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-release_${version}-based-linux-Debian11.6-gcc10.0-arm64.7z"
    url_cached="http://ci-files01-hki.ci.qt.io/input/libclang/qt/libclang-release_${version}-based-linux-Debian11.6-gcc10.0-arm64.7z"
    sha1="b5ff982738dbb6efe1a34ed26ff47fca2b1b3b93"
else
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-release_${version}-based-linux-Rhel8.8-gcc10.0-x86_64.7z"
    url_cached="http://ci-files01-hki.ci.qt.io/input/libclang/qt/libclang-release_${version}-based-linux-Rhel8.8-gcc10.0-x86_64.7z"
    sha1="2a58cc71ad90eb6234c56ef7b141f32361b4312a"
fi

zip="/tmp/libclang.7z"
destination="/usr/local/libclang-$version"

DownloadURL $url_cached $url $sha1 $zip
if command -v 7zr &> /dev/null; then
    sudo 7zr x $zip -o/usr/local/
else
    sudo 7z x $zip -o/usr/local/
fi
sudo mv /usr/local/libclang "$destination"
rm -rf $zip


SetEnvVar "LLVM_INSTALL_DIR" "$destination"
echo "libClang = $version" >> ~/versions.txt
