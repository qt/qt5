#!/usr/bin/env bash
#Copyright (C) 2023 The Qt Company Ltd
#SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

# This script will install Conan
# Note! Python3 is required for Conan installation

os="$1"
params="$2"

# Install Conan to Python user install directory (typically ~./local/)
pip3 install conan --user $params

SetEnvVar "CONAN_REVISIONS_ENABLED" "1"
SetEnvVar "CONAN_V2_MODE" "1"

if [ "$os" == "linux" ]; then
    SetEnvVar "PATH" "/home/qt/.local/bin:\$PATH"
elif [ "$os" == "macos" ]; then
    SetEnvVar "PATH" "/Users/qt/Library/Python/3.7/bin:\$PATH"
fi
