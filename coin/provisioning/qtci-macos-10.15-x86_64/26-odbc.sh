#!/usr/bin/env bash
# Install libiodbc

set -ex

BASEDIR=$(dirname "$0")
"$BASEDIR/../common/macos/libiodbc.sh"
