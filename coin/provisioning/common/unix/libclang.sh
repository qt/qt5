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

libclang_version="18.1.7"

if uname -a |grep -q Darwin; then
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-release_${version}-based-mac.7z"
    url_cached="http://ci-files01-hki.ci.qt.io/input/libclang/qt/libclang-release_${version}-based-mac.7z"
    sha1="9ea511576645ef4abee6d4c27550406e929334d5"
elif test -f /etc/redhat-release && grep "Red Hat" /etc/redhat-release | grep "9" ; then
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-release_${version}-based-linux-Rhel9.2-gcc10.0-x86_64.7z"
    url_cached="http://ci-files01-hki.ci.qt.io/input/libclang/qt/libclang-release_${version}-based-linux-Rhel9.2-gcc10.0-x86_64.7z"
    sha1="32c29d8df726b035e0a97e767c5c3e392aa331e1"
elif test "$PROVISIONING_OS_ID" == "debian" && test "$PROVISIONING_ARCH" == "arm64" ; then
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-release_${version}-based-linux-Debian11.6-gcc10.0-arm64.7z"
    url_cached="http://ci-files01-hki.ci.qt.io/input/libclang/qt/libclang-release_${version}-based-linux-Debian11.6-gcc10.0-arm64.7z"
    sha1="8d876f60c2fe9c55e18fbac0be2acb70bd20d5d1"
elif test "$PROVISIONING_OS_ID" == "ubuntu" && test "$PROVISIONING_ARCH" == "arm64" ; then
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-release_${version}-based-linux-Ubuntu24.04-gcc11.2-arm64.7z"
    url_cached="http://ci-files01-hki.ci.qt.io/input/libclang/qt/libclang-release_${version}-based-linux-Ubuntu24.04-gcc11.2-arm64.7z"
    sha1="5a7bda4fbd2c52ae66557034591d977ba617482c"
elif test "$PROVISIONING_OS_ID" == "ubuntu" && test "$PROVISIONING_ARCH" == "x86_64" ; then
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-release_${version}-based-linux-Ubuntu22.04-gcc11.2-x86_64.7z"
    url_cached="http://ci-files01-hki.ci.qt.io/input/libclang/qt/libclang-release_${version}-based-linux-Ubuntu22.04-gcc11.2-x86_64.7z"
    sha1="b9f8735a148342174d7d763b5475175cd0827441"
else
    version=$libclang_version
    url="https://download.qt.io/development_releases/prebuilt/libclang/qt/libclang-release_${version}-based-linux-Rhel8.8-gcc10.0-x86_64.7z"
    url_cached="http://ci-files01-hki.ci.qt.io/input/libclang/qt/libclang-release_${version}-based-linux-Rhel8.8-gcc10.0-x86_64.7z"
    sha1="a51c5562c9b071250e7971390d55ef21924271ca"
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
