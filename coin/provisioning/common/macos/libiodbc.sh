#!/usr/bin/env bash
# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Install libiodbc

set -ex

# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

# HOMEBREW_DIR depends on acrhitecture
ARCH_TYPE=$(arch)
if [ "$ARCH_TYPE" == "arm64" ]; then
    HOMEBREW_DIR="/opt/homebrew/Library/Taps/local/homebrew-libiodbc/Formula"
else
    HOMEBREW_DIR="/usr/local/Homebrew/Library/Taps/local/homebrew-libiodbc/Formula"
fi

brew tap-new local/libiodbc
cp "${BASH_SOURCE%/*}/libiodbc.rb" "$HOMEBREW_DIR/"
brew install local/libiodbc/libiodbc "$@"

read -r -a arr <<< "$(brew list --versions libiodbc)"
version=${arr[1]}

SetEnvVar "ODBC_ROOT" "$(brew --prefix libiodbc)"

echo "libiodbc = $version" >> ~/versions.txt
