#!/usr/bin/env bash

set -ex

BASEDIR=$(dirname "$0")
. $BASEDIR/../common/shared/sw_versions.txt
VERSION=$libclang_version
URL="http://ci-files01-hki.intra.qt.io/input/libclang/qt/libclang-release_${VERSION//\./}-linux-Rhel7.2-gcc5.3-x86_64.7z"
SHA1="bbdbbc0296f42310077539b7247d285386119ef4"

$BASEDIR/../common/unix/libclang.sh "$URL" "$SHA1" "$VERSION"
