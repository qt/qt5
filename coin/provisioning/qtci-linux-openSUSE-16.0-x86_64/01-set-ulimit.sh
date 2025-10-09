#!/usr/bin/env bash

set -ex

BASEDIR=$(dirname "$0")
"$BASEDIR/../common/linux/set_ulimit.sh"
