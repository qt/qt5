#!/usr/bin/env sh

set -ex

# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"

# Enables the usage of temporary keychains for SSL autotests
SetEnvVar "QT_SSL_USE_TEMPORARY_KEYCHAIN" "1"
