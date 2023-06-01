#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

# This script will install node.js 18.16.0
version="18.16.0"

uname_m="$(uname -m)"
case "$uname_m" in
    x86_64|amd64)
        sha256="44d93d9b4627fe5ae343012d855491d62c7381b236c347f7666a7ad070f26548"
        pkgname="node-v$version-linux-x64.tar.xz"
        dirname="node-v$version-linux-x64"
        ;;
    arm64|aarch64)
        sha256="c81dfa0bada232cb4583c44d171ea207934f7356f85f9184b32d0dde69e2e0ea"
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
