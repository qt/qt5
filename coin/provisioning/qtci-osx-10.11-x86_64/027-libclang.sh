#!/usr/bin/env bash
# requires: 7z

BASEDIR=$(dirname "$0")
# There is only one mac package and common script uses it as a default
$BASEDIR/../common/libclang.sh
