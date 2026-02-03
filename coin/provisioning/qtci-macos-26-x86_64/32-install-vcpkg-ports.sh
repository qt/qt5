#!/usr/bin/env bash

set -ex

BASEDIR=$(dirname "$0")
"$BASEDIR/../common/unix/install-vcpkg-ports.sh" arm64-osx-qt

# Create an alias for arm64-osx-qt, because the built package references this triplet.
ln -s arm64-osx-qt $VCPKG_ROOT/installed/universal-osx-qt
