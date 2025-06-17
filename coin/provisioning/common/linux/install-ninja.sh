#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

# This script will install ninja
version="1.12.1"

uname_m="$(uname -m)"
case "$uname_m" in
    x86_64|amd64)
        sha256="6f98805688d19672bd699fbbfa2c2cf0fc054ac3df1f0e6a47664d963d530255"
        pkgname="ninja-$version-linux-x64.zip"
        dirname="ninja-$version-linux-x64"
        ;;
    arm64|aarch64)
        sha256="5c25c6570b0155e95fce5918cb95f1ad9870df5768653afe128db822301a05a1"
        pkgname="ninja-$version-linux-arm64.zip"
        dirname="ninja-$version-linux-arm64"
        ;;
    *) fatal "Unknown architecture in uname: $uname_m" 43 ;;
esac

internalUrl="http://ci-files01-hki.ci.qt.io/input/ninja/$pkgname"
externalUrl="https://github.com/ninja-build/ninja/releases/download/v$version/$pkgname"

targetFile="$HOME/$pkgname"
DownloadURL "$internalUrl" "$externalUrl" "$sha256" "$targetFile"
echo "Installing ninja ${version}"
sudo unzip -o -q ${targetFile} -d "${HOME}/${dirname}"
rm "$targetFile"

installPrefix="/opt/$dirname"
sudo mv "$HOME/$dirname" "$installPrefix"

SetEnvVar "PATH" "$installPrefix:\$PATH"
SetEnvVar "NINJA_EXECUTABLE" "$installPrefix/ninja"

echo "ninja = $version" >> ~/versions.txt
