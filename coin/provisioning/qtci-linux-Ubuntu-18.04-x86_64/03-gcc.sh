#!/usr/bin/env bash

set -ex

# shellcheck source=../common/linux/gcc.sh
source "${BASH_SOURCE%/*}/../common/linux/gcc.sh"

InstallGCC 9.3.0 50 526bc0ed135e65366080350d0f991157752223c0 b746688bf045a316fc92c3528138ad10d0822b6b
