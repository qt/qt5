#!/usr/bin/env bash

set -ex

BASEDIR=$(dirname "$0")
$BASEDIR/../common/system_updates.sh
