#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

echo "Installing vcpkg ports"

pushd "${BASH_SOURCE%/*}/vcpkg" || exit
cp "${BASH_SOURCE%/*}/../shared/vcpkg-configuration.json" .

"$VCPKG_ROOT/vcpkg" install --triplet x64-linux-qt --x-install-root x64-linux-qt-tmp --debug

mkdir -p "$VCPKG_ROOT/installed"
cp -R x64-linux-qt-tmp/* "$VCPKG_ROOT/installed/"

versions=$(jq -r '.overrides[] | "vcpkg \(.name) = \(.version)"' vcpkg.json)
versions="${versions//vcpkg/\\nvcpkg}"
echo "$versions" >> ~/versions.txt

rm -rf x64-linux-qt-tmp

popd || exit
