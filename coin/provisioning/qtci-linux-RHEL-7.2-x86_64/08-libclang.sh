#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
. $BASEDIR/../common/sw_versions.txt
VERSION=$libclang_version
URL="https://download.qt.io/development_releases/prebuilt/libclang/libclang-release_${VERSION//\./}-linux-Rhel7.2-gcc5.3-x86_64.7z"
SHA1="bbdbbc0296f42310077539b7247d285386119ef4"

$BASEDIR/../common/libclang.sh "$URL" "$SHA1" "$VERSION"
