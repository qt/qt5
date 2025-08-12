#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

echo "Installing vcpkg ports"

pushd "${BASH_SOURCE%/*}/../shared/vcpkg" || exit

install_root=$1-tmp

"$VCPKG_ROOT/vcpkg" install --triplet $1 --x-install-root $install_root --debug

cmake "-DVCPKG_EXECUTABLE=$VCPKG_ROOT/vcpkg"\
    "-DVCPKG_INSTALL_ROOT=$PWD/$install_root"\
    "-DOUTPUT=$HOME/versions.txt"\
    -P\
    "${BASH_SOURCE%/*}/../shared/vcpkg_parse_packages.cmake"

mkdir -p "$VCPKG_ROOT/installed"
cp -R $install_root/* "$VCPKG_ROOT/installed/"

SetEnvVar "VCPKG_INSTALLED_DIR" "$VCPKG_ROOT/installed/"

rm -rf $install_root

popd || exit
