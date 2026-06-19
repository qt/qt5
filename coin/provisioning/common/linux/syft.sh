#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs Syft

# Syft is used for generating SBOM (Software Bill of Materials) files.

# shellcheck source=../unix/InstallFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../unix/InstallFromCompressedFileFromURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"


version="1.45.1"

uname_m="$(uname -m)"
case "$uname_m" in
    x86_64|amd64)
        SHA1="06e1d56173209977df8b11ad955843cb62f874fd"
        arch="amd64"
        ;;
    arm64|aarch64)
        SHA1="c48638b3998066dbd139e94e116a81a6cc6299be"
        arch="arm64"
        ;;
    *) fatal "Unknown architecture in uname: $uname_m" 43 ;;
esac

PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/syft/syft_${version}_linux_${arch}.tar.gz"
AltUrl="https://github.com/anchore/syft/releases/download/v${version}/syft_${version}_linux_${arch}.tar.gz"
targetFolder="/opt/syft-$version"
appPrefix=""

InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$targetFolder" "$appPrefix"

SetEnvVar "PATH" "$targetFolder:\$PATH"

echo "Syft = $version" >> ~/versions.txt
