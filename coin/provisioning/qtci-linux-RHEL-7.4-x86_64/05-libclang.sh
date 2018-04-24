#!/usr/bin/env bash
set -ex

BASEDIR=$(dirname "$0")
. $BASEDIR/../common/shared/sw_versions.txt
VERSION=$libclang_version
URL="https://download.qt.io/development_releases/prebuilt/libclang/libclang-release_${VERSION//\./}-linux-Rhel7.2-gcc5.3-x86_64.7z"
SHA1="71194c4d6065a62ac1a891123df79fd9da311bf0"

$BASEDIR/../common/unix/libclang.sh "$URL" "$SHA1" "$VERSION"
