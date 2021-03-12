#!/usr/bin/env bash

set -ex

# shellcheck source=../common/linux/gcc.sh
source "${BASH_SOURCE%/*}/../common/linux/gcc.sh"

InstallGCC 8.3.0 50 ccccfe4fe9206d111a173c19a21f8700d1133ae8 c27f4499dd263fe4fb01bcc5565917f3698583b2
