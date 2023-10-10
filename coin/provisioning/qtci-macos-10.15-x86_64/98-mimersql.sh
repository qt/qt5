#!/usr/bin/env bash
set -ex

BASEDIR=$(dirname "$0")
"$BASEDIR/../common/macos/mimersql.sh" "macos"
