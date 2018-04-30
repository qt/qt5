#!/usr/bin/env bash

set -ex

BASEDIR=$(dirname "$0")
# There is only one mac package
# shellcheck source=../common/unix/libclang.sh
"$BASEDIR/../common/unix/libclang.sh"
