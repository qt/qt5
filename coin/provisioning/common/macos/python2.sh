#!/usr/bin/env bash
# Copyright (C) 2018 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs python2

# shellcheck source=./InstallPKGFromURL.sh
source "${BASH_SOURCE%/*}/InstallPKGFromURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"
# shellcheck source=./pip.sh
source "${BASH_SOURCE%/*}/pip.sh"

PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/mac/python-2.7.16-macosx10.6.pkg"
AltUrl="https://www.python.org/ftp/python/2.7.16/python-2.7.16-macosx10.6.pkg"
SHA1="895a8327a58e7c0e58852638ab3d84843643535b"
DestDir="/"

InstallPKGFromURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$DestDir"

InstallPip python2.7

echo "Configure pip"
/Library/Frameworks/Python.framework/Versions/2.7/bin/pip config --user set global.index https://ci-files01-hki.ci.qt.io/input/python_module_cache
/Library/Frameworks/Python.framework/Versions/2.7/bin/pip config --user set global.extra-index-url https://pypi.org/simple/

/Library/Frameworks/Python.framework/Versions/2.7/bin/pip install virtualenv

SetEnvVar "PATH" "/Library/Frameworks/Python.framework/Versions/2.7/bin/:\$PATH"

echo "python2 = 2.7.16" >> ~/versions.txt

