#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2018 The Qt Company Ltd.
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

# This script installs python2

# shellcheck source=./InstallPKGFromURL.sh
source "${BASH_SOURCE%/*}/InstallPKGFromURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"
# shellcheck source=./pip.sh
source "${BASH_SOURCE%/*}/pip.sh"

PrimaryUrl="http://ci-files01-hki.intra.qt.io/input/mac/python-2.7.16-macosx10.6.pkg"
AltUrl="https://www.python.org/ftp/python/2.7.16/python-2.7.16-macosx10.6.pkg"
SHA1="895a8327a58e7c0e58852638ab3d84843643535b"
DestDir="/"

InstallPKGFromURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$DestDir"

InstallPip python2.7

/Library/Frameworks/Python.framework/Versions/2.7/bin/pip install virtualenv

SetEnvVar "PATH" "/Library/Frameworks/Python.framework/Versions/2.7/bin/:\$PATH"

echo "python2 = 2.7.16" >> ~/versions.txt

