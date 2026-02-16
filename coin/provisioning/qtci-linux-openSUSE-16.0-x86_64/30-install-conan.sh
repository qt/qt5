#!/usr/bin/env bash

set -ex

BASEDIR=$(dirname "$0")
"$BASEDIR/../common/unix/install-conan.sh" "linux"
