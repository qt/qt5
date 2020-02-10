#!/usr/bin/env bash

set -ex

# shellcheck source=../common/linux/gcc.sh
source "${BASH_SOURCE%/*}/../common/linux/gcc.sh"

InstallGCC 9.2.0 50 2b3873263d4d6b09b37102078d80dcd7016b9392 44975966b15bca922ba64efa8ec3257726a79153
