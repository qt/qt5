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

PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/mac/python-3.11.9-macos11.pkg"
AltUrl="https://www.python.org/ftp/python/3.11.9/python-3.11.9-macos11.pkg"
SHA1="d156e22e4f8902c0ebdf466a3a01832e0f0a85d8"
DestDir="/"

InstallPKGFromURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$DestDir"

echo "Configure pip"
/Library/Frameworks/Python.framework/Versions/3.11/bin/pip3 config --user set global.index https://ci-files01-hki.ci.qt.io/input/python_module_cache
/Library/Frameworks/Python.framework/Versions/3.11/bin/pip3 config --user set global.extra-index-url https://pypi.org/simple/

/Library/Frameworks/Python.framework/Versions/3.11/bin/pip3 install virtualenv wheel html5lib
/Library/Frameworks/Python.framework/Versions/3.11/bin/pip3 install -r ${BASH_SOURCE%/*}/../shared/requirements.txt

SetEnvVar "PYTHON3_PATH" "/Library/Frameworks/Python.framework/Versions/3.11/bin"
SetEnvVar "PIP3_PATH" "/Library/Frameworks/Python.framework/Versions/3.11/bin"
SetEnvVar "SBOM_PYTHON_APPS_PATH" "/Library/Frameworks/Python.framework/Versions/3.11/bin"

# Set SBOM_PYTHON_INTERP_PATH to Python3 instance which was used to install SBOM packages from requirements
SetEnvVar "SBOM_PYTHON_INTERP_PATH" "/Library/Frameworks/Python.framework/Versions/3.11/bin/python3"

# Install Python certificates. Required at least for emsdk installation
open /Applications/Python\ 3.11/Install\ Certificates.command

echo "python3 = 3.11.9" >> ~/versions.txt
