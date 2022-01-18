#!/usr/bin/env bash

set +e

# shellcheck disable=SC1091
source /opt/rh/devtoolset-4/enable

set -ex

# shellcheck source=../common/unix/openssl_for_android.sh
source "${BASH_SOURCE%/*}/../common/unix/openssl_for_android.sh"
