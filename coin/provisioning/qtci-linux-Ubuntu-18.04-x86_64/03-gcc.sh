#!/usr/bin/env bash

set -ex

# shellcheck source=../common/linux/gcc.sh
source "${BASH_SOURCE%/*}/../common/linux/gcc.sh"

InstallGCC 8.2.0 50 19e40bea7df5dbadb22eec09ada621ecd9235687 19926bdb6c4b58891015929853d41aeff019d400

