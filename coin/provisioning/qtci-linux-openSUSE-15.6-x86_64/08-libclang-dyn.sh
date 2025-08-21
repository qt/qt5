#!/usr/bin/env bash

set -ex

BASEDIR=$(dirname "$0")
# shellcheck source=../common/unix/libclang-dyn.sh
"$BASEDIR/../common/unix/libclang-dyn.sh"
