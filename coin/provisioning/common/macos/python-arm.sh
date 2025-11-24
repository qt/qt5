#!/usr/bin/env bash
# Copyright (C) 2025 The Qt Company Ltd.
# Copyright (C) 2017 Pelagicore AG
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs python3 on macOS ARM hosts.

# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

# Use 3.12 as a default python
# Note: Make sure that it's a version where dependencies are stored in CI-files.
python_ver="3.12.11"

export PYTHON_BUILD_MIRROR_URL="https://ci-files01-hki.ci.qt.io/input/python/"
export PYTHON_BUILD_MIRROR_URL_SKIP_CHECKSUM=1
pyenv install "$python_ver"

/Users/qt/.pyenv/versions/$python_ver/bin/pip3 install --user virtualenv wheel html5lib
/Users/qt/.pyenv/versions/$python_ver/bin/pip3 install --user -r ${BASH_SOURCE%/*}/../shared/requirements.txt

SetEnvVar "PYTHON3_PATH" "/Users/qt/.pyenv/versions/$python_ver/bin/"
SetEnvVar "PIP3_PATH" "/Users/qt/.pyenv/versions/$python_ver/bin/"
SetEnvVar "PATH" "\$PYTHON3_PATH:\$PATH"

# Provisioning during installation says:
# 'The script sbom2doc is installed in '$HOME/.local/bin' which is not on PATH.'
# hence the explicit assignment to SBOM_PYTHON_APPS_PATH.
SetEnvVar "SBOM_PYTHON_APPS_PATH" "/Users/qt/.local/bin"

# Set SBOM_PYTHON_INTERP_PATH to Python3 instance which was used to install SBOM packages from requirements
SetEnvVar "SBOM_PYTHON_INTERP_PATH" "/Users/qt/.pyenv/versions/$python_ver/bin/python3"

echo "python3 = $python_ver" >> ~/versions.txt
