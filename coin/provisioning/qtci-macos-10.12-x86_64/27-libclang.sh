#!/usr/bin/env bash

set -ex

BASEDIR=$(dirname "$0")
# There is only one mac package
$BASEDIR/../common/unix/libclang.sh
