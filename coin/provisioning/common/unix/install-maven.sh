#!/usr/bin/env bash
# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# shellcheck source=./DownloadURL.sh
source "${BASH_SOURCE%/*}/DownloadURL.sh"
# shellcheck source=./SetEnvVar.sh
source "${BASH_SOURCE%/*}/SetEnvVar.sh"

# This script will install maven 3.9.11
version="3.9.11"

sha256="c084cde986ba878da4370bde009ab0a0a1936343"
pkgname="apache-maven-$version-bin.tar.gz"
dirname="apache-maven-$version"

internalUrl="http://ci-files01-hki.ci.qt.io/input/qtopenapi/maven/$pkgname"
externalUrl="https://dlcdn.apache.org/maven/maven-3/3.9.11/binaries/$pkgname"

targetFile="$HOME/$pkgname"
DownloadURL "$internalUrl" "$externalUrl" "$sha256" "$targetFile"
echo "Installing Maven"
tar -xzf "$targetFile" -C "$HOME"
rm "$targetFile"

sudo mkdir -p "/opt/maven/"
installPrefix="/opt/maven/$dirname"
sudo mv "$HOME/$dirname" "$installPrefix"

SetEnvVar "PATH" "$installPrefix/bin:$PATH"
echo "Maven = $version" >> ~/versions.txt

