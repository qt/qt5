#!/usr/bin/env bash
# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex
os="$1"
# shellcheck source=./DownloadURL.sh
source "${BASH_SOURCE%/*}/DownloadURL.sh"
# shellcheck source=./SetEnvVar.sh
source "${BASH_SOURCE%/*}/SetEnvVar.sh"

# This script will install go 1.26.2
version="1.26.2"

if [[ "$os" == "linux" ]]; then
    uname_m="$(uname -m)"
    case "$uname_m" in
        x86_64|amd64)
            sha256="990e6b4bbba816dc3ee129eaeaf4b42f17c2800b88a2166c265ac1a200262282"
            pkgname="go$version.linux-amd64.tar.gz"
            dirname="go$version.linux-amd64"
            ;;
        arm64|aarch64)
            sha256="c958a1fe1b361391db163a485e21f5f228142d6f8b584f6bef89b26f66dc5b23"
            pkgname="go$version.linux-arm64.tar.gz"
            dirname="go$version.linux-arm64"
            ;;
        *) fatal "Unknown architecture in uname: $uname_m" ;;
    esac
elif [ "$os" == "macos" ]; then
    uname_m="$(uname -m)"
    case "$uname_m" in
        x86_64|amd64)
            sha256="bc3f1500d9968c36d705442d90ba91addf9271665033748b82532682e90a7966"
            pkgname="go$version.darwin-amd64.tar.gz"
            dirname="go$version.darwin-amd64"
            ;;
        arm64|aarch64)
            sha256="32af1522bf3e3ff3975864780a429cc0b41d190ec7bf90faa661d6d64566e7af"
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

