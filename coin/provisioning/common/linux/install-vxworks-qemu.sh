#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

# shellcheck source=../unix/InstallFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../unix/InstallFromCompressedFileFromURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

QEMU_VER="8.2.3"
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/qemu/qemu-$QEMU_VER.tar.xz"
AltUrl="https://download.qemu.org/qemu-$QEMU_VER.tar.xz"
SHA1="1b29c8105cf8d15b9e7fb6f8e85170b6c54a1788"
InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$SHA1" "/tmp" "$appPrefix"

targetFolder=/tmp/qemu-${QEMU_VER}
mkdir -p "$targetFolder/build"
cd "$targetFolder/build"
../configure --target-list=arm-softmmu,x86_64-softmmu --prefix=/opt/qemu-${QEMU_VER}
make -j8 -s
sudo make -s install
sudo mkdir -p /usr/share/qemu/keymaps
sudo cp -r "$targetFolder/build/pc-bios/keymaps" "/usr/share/qemu/"
rm -rf $targetFolder

SetEnvVar "VXWORKS_QEMU" "/opt/qemu-$QEMU_VER"
