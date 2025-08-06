#!/usr/bin/env bash

set -ex

BASEDIR=$(dirname "$0")
"$BASEDIR/../common/unix/install-vcpkg-ports.sh" arm64-osx-qt --host-triplet=arm64-osx
"$BASEDIR/../common/unix/install-vcpkg-ports.sh" x64-osx-qt --host-triplet=x64-osx

python3 -m lipomerge $VCPKG_ROOT/installed/arm64-osx-qt $VCPKG_ROOT/installed/x64-osx-qt $VCPKG_ROOT/installed/universal-osx-qt
find $VCPKG_ROOT/installed/universal-osx-qt -name '*.cmake' -exec sed -i .bak -E 's,/(arm64|x64)-osx(-qt)?/,/universal-osx-qt/,g' '{}' \;
