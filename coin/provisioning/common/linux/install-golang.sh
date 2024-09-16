#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

# This script will install go 1.22.4
version="1.22.4"

uname_m="$(uname -m)"
case "$uname_m" in
    x86_64|amd64)
        sha256="ba79d4526102575196273416239cca418a651e049c2b099f3159db85e7bade7d"
        pkgname="go$version.linux-amd64.tar.gz"
        dirname="go$version.linux-amd64"
        ;;
    arm64|aarch64)
        sha256="a8e177c354d2e4a1b61020aca3562e27ea3e8f8247eca3170e3fa1e0c2f9e771"
        pkgname="go$version.linux-arm64.tar.gz"
        dirname="go$version.linux-arm64"
        ;;
    *) fatal "Unknown architecture in uname: $uname_m" 43 ;;
esac

internalUrl="http://ci-files01-hki.ci.qt.io/input/go/linux/$pkgname"
externalUrl="https://go.dev/dl/$pkgname"

targetFile="$HOME/$pkgname"
DownloadURL "$internalUrl" "$externalUrl" "$sha256" "$targetFile"
echo "Installing Go"
tar -xzf "$targetFile" -C "$HOME"
rm "$targetFile"

installPrefix="/opt/$dirname"
sudo mv "$HOME/go" "$installPrefix"

SetEnvVar "PATH" "$installPrefix/bin:\$PATH"

echo "Go = $version" >> ~/versions.txt
