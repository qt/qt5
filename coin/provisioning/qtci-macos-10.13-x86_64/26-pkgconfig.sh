#!/usr/bin/env bash
# Install pkgconfig

set -ex

BASEDIR=$(dirname "$0")
"$BASEDIR/../common/macos/pkgconfig.sh"
