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
. "$PROVISIONING_DIR"/common/unix/common.sourced.sh

libclang_version="15.0.0"

if uname -a |grep -q Darwin; then
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-release_${version}-based-mac.7z"
    url_cached="http://ci-files01-hki.intra.qt.io/input/libclang/qt/libclang-release_${version}-based-mac.7z"
    sha1="6d916a17459c81551dde47580ae3f071e93338a5"
elif test -f /etc/redhat-release && cat /etc/redhat-release | grep "Red Hat" | grep -v "8" ; then
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-release_${version}-based-linux-Rhel8.4-gcc10.0-x86_64.7z"
    url_cached="http://ci-files01-hki.intra.qt.io/input/libclang/qt/libclang-release_${version}-based-linux-Rhel8.4-gcc10.0-x86_64.7z"
    sha1="6ca035bb522022d34d61759e0460845832933b5c"
elif [ "$PROVISIONING_OS_ID" = ubuntu ]; then
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-release_${version}-based-linux-Ubuntu22.04-gcc11.2-x86_64.7z"
    url_cached="http://ci-files01-hki.intra.qt.io/input/libclang/qt/libclang-release_${version}-based-linux-Ubuntu22.04-gcc11.2-x86_64.7z"
    sha1="dd170ec762a7ec8ac84b4b5cac3a422514e5b030"
elif  [ "$PROVISIONING_OS_ID" = debian ]; then
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-release_${version}-based-linux-Debian11.6-gcc10.0-arm64.7z"
    url_cached="http://ci-files01-hki.intra.qt.io/input/libclang/qt/libclang-release_${version}-based-linux-Debian11.6-gcc10.0-arm64.7z"
    sha1="c7b1d28ef835192b033f317c96686780d85d8eba"
else
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-release_${version}-based-linux-Ubuntu20.04-gcc9.3-x86_64.7z"
    url_cached="http://ci-files01-hki.intra.qt.io/input/libclang/qt/libclang-release_${version}-based-linux-Ubuntu20.04-gcc9.3-x86_64.7z"
    sha1="bd6615012b8bdb2720a45ede56e05f6db7191843"
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


echo "export LLVM_INSTALL_DIR=$destination" >> ~/.bash_profile
echo "libClang = $version" >> ~/versions.txt

# This is a hacked static build of libclang which requires special
# handling on the qdoc side.
SetEnvVar "QDOC_USE_STATIC_LIBCLANG" "1"
