#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# Copyright (C) 2017 Pelagicore AG
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs python3

# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"

pyenv install 3.9.7

/Users/qt/.pyenv/versions/3.9.7/bin/pip3 install --user virtualenv wheel html5lib
/Users/qt/.pyenv/versions/3.9.7/bin/pip3 install --user -r ${BASH_SOURCE%/*}/../common/shared/sbom_requirements.txt

SetEnvVar "PYTHON3_PATH" "/Users/qt/.pyenv/versions/3.9.7/bin/"
SetEnvVar "PIP3_PATH" "/Users/qt/.pyenv/versions/3.9.7/bin/"
# Use 3.9 as a default python
SetEnvVar "PATH" "\$PYTHON3_PATH:\$PATH"

# QtWebengine still requires python2
pyenv install 2.7.18
SetEnvVar "PYTHON2_PATH" "/Users/qt/.pyenv/versions/2.7.18/bin/"

echo "python3 = 3.9.7" >> ~/versions.txt
echo "python2 = 2.7.18" >> ~/versions.txt
