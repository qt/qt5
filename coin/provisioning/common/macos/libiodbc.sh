#!/usr/bin/env bash
# Copyright (C) 2018 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Install libiodbc

set -ex

# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

brew install --formula "${BASH_SOURCE%/*}/libiodbc.rb" "$@"

# CPLUS_INCLUDE_PATH is set so clang and configure can find libiodbc

read -r -a arr <<< "$(brew list --versions libiodbc)"
version=${arr[1]}

SetEnvVar "CPLUS_INCLUDE_PATH" "/usr/local/Cellar/libiodbc/$version/include${CPLUS_INCLUDE_PATH:+:}${CPLUS_INCLUDE_PATH}"
SetEnvVar "LIBRARY_PATH" "/usr/local/Cellar/libiodbc/$version/lib${LIBRARY_PATH:+:}${LIBRARY_PATH}"

echo "libiodbc = $version" >> ~/versions.txt
