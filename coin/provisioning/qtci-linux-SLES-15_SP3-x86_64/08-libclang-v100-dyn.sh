#!/usr/bin/env bash

set -ex

BASEDIR=$(dirname "$0")
# shellcheck source=../common/unix/libclang-v100-dyn.sh
"$BASEDIR/../common/unix/libclang-v100-dyn.sh"
