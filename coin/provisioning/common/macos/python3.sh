#!/usr/bin/env bash
# Copyright (C) 2019 The Qt Company Ltd.
# Copyright (C) 2017 Pelagicore AG
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs python3

# shellcheck source=./InstallPKGFromURL.sh
source "${BASH_SOURCE%/*}/InstallPKGFromURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"
# shellcheck source=./pip.sh
source "${BASH_SOURCE%/*}/pip.sh"

PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/mac/python-3.9.6-macos11.pkg"
AltUrl="https://www.python.org/ftp/python/3.9.6/python-3.9.6-macos11.pkg"
SHA1="2af5277c2e197719eb4b820430dee5d89e2577b6"
DestDir="/"

InstallPKGFromURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$DestDir"

InstallPip python3.9

echo "Configure pip"
/Library/Frameworks/Python.framework/Versions/3.9/bin/pip config --user set global.index https://ci-files01-hki.ci.qt.io/input/python_module_cache
/Library/Frameworks/Python.framework/Versions/3.9/bin/pip config --user set global.extra-index-url https://pypi.org/simple/

/Library/Frameworks/Python.framework/Versions/3.9/bin/pip3 install virtualenv wheel html5lib

SetEnvVar "PYTHON3_PATH" "/Library/Frameworks/Python.framework/Versions/3.9/bin"
SetEnvVar "PIP3_PATH" "/Library/Frameworks/Python.framework/Versions/3.9/bin"

# Install Python certificates. Required at least for emsdk installation
open /Applications/Python\ 3.9/Install\ Certificates.command

echo "python3 = 3.9.6" >> ~/versions.txt
