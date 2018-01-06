#!/usr/bin/env sh

set -ex

# Enables the usage of temporary keychains for SSL autotests
echo "export QT_SSL_USE_TEMPORARY_KEYCHAIN=1" >> ~/.bashrc
