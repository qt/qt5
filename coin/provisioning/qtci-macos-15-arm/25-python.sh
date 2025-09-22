#!/usr/bin/env bash
# Copyright (C) 2025 The Qt Company Ltd.
# Copyright (C) 2017 Pelagicore AG
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs python3

# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"

pyenv install 3.12.11

/Users/qt/.pyenv/versions/3.12.11/bin/pip3 install --user virtualenv wheel html5lib
/Users/qt/.pyenv/versions/3.12.11/bin/pip3 install --user -r ${BASH_SOURCE%/*}/../common/shared/requirements.txt

SetEnvVar "PYTHON3_PATH" "/Users/qt/.pyenv/versions/3.12.11/bin/"
SetEnvVar "PIP3_PATH" "/Users/qt/.pyenv/versions/3.12.11/bin/"
# Use 3.9 as a default python
SetEnvVar "PATH" "\$PYTHON3_PATH:\$PATH"

# Provisioning during installation says:
# 'The script sbom2doc is installed in '$HOME/.local/bin' which is not on PATH.'
# hence the explicit assignment to SBOM_PYTHON_APPS_PATH.
SetEnvVar "SBOM_PYTHON_APPS_PATH" "/Users/qt/.local/bin"

echo "python3 = 3.12.11" >> ~/versions.txt
