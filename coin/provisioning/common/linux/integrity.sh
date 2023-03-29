#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs needed toolchains for INTEGRITY

# shellcheck source=../unix/InstallFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../unix/InstallFromCompressedFileFromURL.sh"
# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

urlToolchainEs7="http://ci-files01-hki.ci.qt.io/input/integrity/integrity_toolchain_es7_05102022.zip"
urlLibeglmegapack="http://ci-files01-hki.ci.qt.io/input/integrity/integrity_libeglmegapack.zip"
SHA1_toolchainEs7="a95e11996d89218ac93493484e483d169976f565"
SHA1_Libeglmegapack="7f8ca64132eaea66202ea8db7f71f3300aab0777"
targetFolder="$HOME"
appPrefix=""

toolchain_file="${BASH_SOURCE%/*}/cmake_toolchain_files/integrity_toolchain.cmake"

echo "Install Integrity toolchain es7"
InstallFromCompressedFileFromURL "$urlToolchainEs7" "$urlToolchainEs7" "$SHA1_toolchainEs7" "$targetFolder" "$appPrefix"

echo "Install Integrity toolchain addons"
DownloadURL "$urlLibeglmegapack" "$urlLibeglmegapack" "$SHA1_Libeglmegapack" "/tmp/integrity_libeglmegapack.zip"
unzip "/tmp/integrity_libeglmegapack.zip" -d "/tmp"
mv /tmp/toolchain/* "$targetFolder/toolchain"
mv "$targetFolder/toolchain" "$targetFolder/integrity_toolchain"
cp "$toolchain_file" "$targetFolder/integrity_toolchain/toolchain.cmake"
sudo rm -fr /tmp/toolchain
