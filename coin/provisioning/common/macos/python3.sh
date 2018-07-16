#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
## Copyright (C) 2017 Pelagicore AG
## Contact: http://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL21$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see http://www.qt.io/terms-conditions. For further
## information use the contact form at http://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 2.1 or version 3 as published by the Free
## Software Foundation and appearing in the file LICENSE.LGPLv21 and
## LICENSE.LGPLv3 included in the packaging of this file. Please review the
## following information to ensure the GNU Lesser General Public License
## requirements will be met: https://www.gnu.org/licenses/lgpl.html and
## http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
##
## As a special exception, The Qt Company gives you certain additional
## rights. These rights are described in The Qt Company LGPL Exception
## version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
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

PrimaryUrl="http://ci-files01-hki.intra.qt.io/input/mac/python-3.6.1-macosx10.6.pkg"
AltUrl="https://www.python.org/ftp/python/3.6.1/python-3.6.1-macosx10.6.pkg"
SHA1="ae0c749544c2d573c3cc29c4c2d7d9a595db28f9"
DestDir="/"

InstallPKGFromURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$DestDir"

InstallPip python3.6

/Library/Frameworks/Python.framework/Versions/3.6/bin/pip3 install virtualenv wheel

SetEnvVar "PYTHON3_PATH" "/Library/Frameworks/Python.framework/Versions/3.6/bin"
SetEnvVar "PIP3_PATH" "/Library/Frameworks/Python.framework/Versions/3.6/bin"

# Install all needed packages in a special wheel cache directory
/Library/Frameworks/Python.framework/Versions/3.6/bin/pip3 wheel --wheel-dir $HOME/python3-wheels -r ${BASH_SOURCE%/*}/../shared/requirements.txt
SetEnvVar "PYTHON3_WHEEL_CACHE" "$HOME/python3-wheels"

echo "python3 = 3.6.1" >> ~/versions.txt

