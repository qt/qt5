#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

# This script will install UPX 4.2.4
version="4.2.4"

uname_m="$(uname -m)"
case "$uname_m" in
    x86_64|amd64)
        sha256="75cab4e57ab72fb4585ee45ff36388d280c7afd72aa03e8d4b9c3cbddb474193"
        pkgname="upx-$version-amd64_linux.tar.xz"
        dirname="upx-$version-amd64_linux"
        ;;
    arm64|aarch64)
        sha256="6bfeae6714e34a82e63245289888719c41fd6af29f749a44ae3d3d166ba6a1c9"
        pkgname="upx-$version-arm64_linux.tar.xz"
        dirname="upx-$version-arm64_linux"
        ;;
    *) fatal "Unknown architecture in uname: $uname_m" 43 ;;
esac

internalUrl="http://ci-files01-hki.ci.qt.io/input/upx/linux/$pkgname"
externalUrl="https://github.com/upx/upx/releases/download/v$version/$pkgname"

targetFile="$HOME/$pkgname"
DownloadURL "$internalUrl" "$externalUrl" "$sha256" "$targetFile"
echo "Installing UPX"
tar -xJf "$targetFile" -C "$HOME"
rm "$targetFile"

installPrefix="/opt/$dirname"
sudo mv "$HOME/$dirname" "$installPrefix"

SetEnvVar "PATH" "$installPrefix:\$PATH"

echo "UPX = $version" >> ~/versions.txt
