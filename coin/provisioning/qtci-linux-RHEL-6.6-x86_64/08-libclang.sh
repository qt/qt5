#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
. $BASEDIR/../common/sw_versions.txt
VERSION=$libclang_version
URL="https://download.qt.io/development_releases/prebuilt/libclang/libclang-release_${VERSION//\./}-linux-Rhel6.6-gcc4.9-x86_64.7z"
SHA1="c7466109628418a6aa3db8b3f5825f847f1c4952"

$BASEDIR/../common/libclang.sh "$URL" "$SHA1" "$VERSION"
