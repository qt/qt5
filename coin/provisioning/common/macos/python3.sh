#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
## Copyright (C) 2017 Pelagicore AG
## Contact: https://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see https://www.qt.io/terms-conditions. For further
## information use the contact form at https://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 3 as published by the Free Software
## Foundation and appearing in the file LICENSE.LGPL3 included in the
## packaging of this file. Please review the following information to
## ensure the GNU Lesser General Public License version 3 requirements
## will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 2.0 or (at your option) the GNU General
## Public license version 3 or any later version approved by the KDE Free
## Qt Foundation. The licenses are as published by the Free Software
## Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
## included in the packaging of this file. Please review the following
## information to ensure the GNU General Public License requirements will
## be met: https://www.gnu.org/licenses/gpl-2.0.html and
## https://www.gnu.org/licenses/gpl-3.0.html.
##
## $QT_END_LICENSE$
##
#############################################################################

# This script installs python3

# shellcheck source=./InstallPKGFromURL.sh
source "${BASH_SOURCE%/*}/InstallPKGFromURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"
# shellcheck source=./pip.sh
source "${BASH_SOURCE%/*}/pip.sh"

PrimaryUrl="http://ci-files01-hki.intra.qt.io/input/mac/python-3.9.6-macos11.pkg"
AltUrl="https://www.python.org/ftp/python/3.9.6/python-3.9.6-macos11.pkg"
SHA1="2af5277c2e197719eb4b820430dee5d89e2577b6"
DestDir="/"

InstallPKGFromURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$DestDir"

InstallPip python3.9

/Library/Frameworks/Python.framework/Versions/3.9/bin/pip3 install virtualenv wheel html5lib

SetEnvVar "PYTHON3_PATH" "/Library/Frameworks/Python.framework/Versions/3.9/bin"
SetEnvVar "PIP3_PATH" "/Library/Frameworks/Python.framework/Versions/3.9/bin"

# Install Python certificates. Required at least for emsdk installation
open /Applications/Python\ 3.9/Install\ Certificates.command

echo "python3 = 3.9.6" >> ~/versions.txt
