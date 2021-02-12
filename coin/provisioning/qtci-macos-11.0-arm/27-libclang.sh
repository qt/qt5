#!/usr/bin/env bash

set -ex

BASEDIR=$(dirname "$0")
# There is only one mac package and common script uses it as a default
"$BASEDIR/../common/unix/libclang.sh"
