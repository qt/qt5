#!/bin/bash

set -ex

# shellcheck source=../common/unix/install-openssl.sh
source "${BASH_SOURCE%/*}/../common/unix/install-openssl.sh" "linux"
