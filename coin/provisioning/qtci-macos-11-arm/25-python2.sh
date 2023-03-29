#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# Copyright (C) 2017 Pelagicore AG
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
set -ex

# This script installs python2

# shellcheck source=../common/macos/InstallPKGFromURL.sh
source "${BASH_SOURCE%/*}/../common/macos/InstallPKGFromURL.sh"
# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"
# shellcheck source=../common/macos/pip.sh
source "${BASH_SOURCE%/*}/../common/macos/pip.sh"

InstallPip python2.7

/usr/local/bin/pip install virtualenv

SetEnvVar "PATH" "/Library/Frameworks/Python.framework/Versions/2.7/bin/:\$PATH"

echo "python2 = 2.7.16" >> ~/versions.txt
