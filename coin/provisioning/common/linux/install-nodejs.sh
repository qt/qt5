#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

# This script will install node.js 18.16.0
version="22.21.1"

uname_m="$(uname -m)"
case "$uname_m" in
    x86_64|amd64)
        sha256="680d3f30b24a7ff24b98db5e96f294c0070f8f9078df658da1bce1b9c9873c88"
        pkgname="node-v$version-linux-x64.tar.xz"
        dirname="node-v$version-linux-x64"
        ;;
    arm64|aarch64)
        sha256="e660365729b434af422bcd2e8e14228637ecf24a1de2cd7c916ad48f2a0521e1"
        pkgname="node-v$version-linux-arm64.tar.xz"
        dirname="node-v$version-linux-arm64"
        ;;
    *) fatal "Unknown architecture in uname: $uname_m" 43 ;;
esac

internalUrl="http://ci-files01-hki.ci.qt.io/input/nodejs/$pkgname"
externalUrl="https://nodejs.org/dist/v$version/$pkgname"

targetFile="$HOME/$pkgname"
DownloadURL "$internalUrl" "$externalUrl" "$sha256" "$targetFile"
echo "Installing nodejs"
tar -xJf "$targetFile" -C "$HOME"
rm "$targetFile"

installPrefix="/opt/$dirname"
sudo mv "$HOME/$dirname" "$installPrefix"

SetEnvVar "PATH" "$installPrefix/bin:\$PATH"

echo "nodejs = $version" >> ~/versions.txt
