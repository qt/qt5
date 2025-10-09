#!/usr/bin/env bash
# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex
os="$1"
# shellcheck source=./DownloadURL.sh
source "${BASH_SOURCE%/*}/DownloadURL.sh"
# shellcheck source=./SetEnvVar.sh
source "${BASH_SOURCE%/*}/SetEnvVar.sh"

# This script will install go 1.25.2
version="1.25.2"

if [[ "$os" == "linux" ]]; then
    uname_m="$(uname -m)"
    case "$uname_m" in
        x86_64|amd64)
            sha256="a08c8c36946c86890ca46185765da34442ce64aa"
            pkgname="go$version.linux-amd64.tar.gz"
            dirname="go$version.linux-amd64"
            ;;
        arm64|aarch64)
            sha256="13690a4ecac03e6cca6988a6d2ce80bfa938eb7b"
            pkgname="go$version.linux-arm64.tar.gz"
            dirname="go$version.linux-arm64"
            ;;
        *) fatal "Unknown architecture in uname: $uname_m" ;;
    esac
elif [ "$os" == "macos" ]; then
    uname_m="$(uname -m)"
    case "$uname_m" in
        x86_64|amd64)
            sha256="eda89df8fd85a49e4046f85340236248a5d2a7cd"
            pkgname="go$version.darwin-amd64.tar.gz"
            dirname="go$version.darwin-amd64"
            ;;
        arm64|aarch64)
            sha256="1745a71d18f9946f7aac9f9528e3227c8132cc08"
            pkgname="go$version.darwin-arm64.tar.gz"
            dirname="go$version.darwin-arm64"
            ;;
        *) fatal "Unknown architecture in uname: $uname_m" ;;
    esac
fi

internalUrl="http://ci-files01-hki.ci.qt.io/input/qtopenapi/go/$pkgname"
externalUrl="https://go.dev/dl/$pkgname"

targetFile="$HOME/$pkgname"
DownloadURL "$internalUrl" "$externalUrl" "$sha256" "$targetFile"
echo "Installing Go"
tar -xzf "$targetFile" -C "$HOME"
rm "$targetFile"

sudo mkdir -p "/opt/golang/"
installPrefix="/opt/golang/$dirname"
sudo mv "$HOME/go" "$installPrefix"

SetEnvVar "PATH" "$installPrefix/bin:$PATH"
echo "Go = $version" >> ~/versions.txt

