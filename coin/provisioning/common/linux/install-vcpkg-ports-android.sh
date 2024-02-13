#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

echo "Installing vcpkg android ports"

pushd "${BASH_SOURCE%/*}/vcpkg" || exit
cp "${BASH_SOURCE%/*}/../shared/vcpkg-configuration.json" .

"$VCPKG_ROOT/vcpkg" install --triplet x86-android-qt --x-install-root x86-android-qt-tmp --debug
"$VCPKG_ROOT/vcpkg" install --triplet x86_64-android-qt --x-install-root x86_64-android-qt-tmp --debug

mkdir -p "$VCPKG_ROOT/installed"
cp -R x86-android-qt-tmp/* "$VCPKG_ROOT/installed/"
cp -R x86_64-android-qt-tmp/* "$VCPKG_ROOT/installed/"

versions=$(jq -r '.overrides[] | "vcpkg \(.name) for android = \(.version)"' vcpkg.json)
versions="${versions//vcpkg/\\nvcpkg}"
echo "$versions" >> ~/versions.txt

rm -rf x86-android-qt-tmp
rm -rf x86_64-android-qt-tmp

popd || exit
