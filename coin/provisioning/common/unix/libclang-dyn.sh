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

version="20.1.3"
baseUrl="https://download.qt.io/development_releases/prebuilt/libclang"
cachedUrl="http://ci-files01-hki.ci.qt.io/input/libclang/dynamic"

if uname -a |grep -q Darwin; then
    filename="libclang-release_20.1.3-based-macos-universal.7z"
    sha1="21f403beec492b88a0043b90a2600f1fc60ec271"
elif [ -f /etc/redhat-release ] || [ -f /etc/centos-release ] ; then
    filename="libclang-release_20.1.3-based-linux-Rhel8.8-gcc10.3-x86_64.7z"
    sha1="e91e52c82076b69bd41189afe5c1feb82ab64b64"
else
    filename="libclang-release_20.1.3-based-linux-Ubuntu22.04-gcc11.4-x86_64.7z"
    sha1="878a8ec09ed649635ad1707243a06a0c045b712f"
fi

url="${baseUrl}/${filename}"
url_cached="${cachedUrl}/${filename}"
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
