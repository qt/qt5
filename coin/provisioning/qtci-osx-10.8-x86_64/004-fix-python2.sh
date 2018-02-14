#!/usr/bin/env bash
set -e
#############################################################################
##
## Copyright (C) 2018 The Qt Company Ltd.
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
source "${BASH_SOURCE%/*}/../common/macos/InstallPKGFromURL.sh"

# macOS 10.8 template doesn't have working virtualenv installation.
# To fix that, we first have to install pip to install virtualenv.
# But before doing that, we have to delete all broken/wrong python
# installs from the machine and install proper Python version
# instead the default one.

sudo rm -rf /opt/local/Library/Frameworks/Python.framework/
sudo rm -rf /Library/Frameworks/Python.framework/
sudo rm -rf /System/Library/Frameworks/Python.framework/Versions/2.7/
sudo rm -rf /Users/qt/Python-2.7.6
sudo rm -rf /Users/qt/python27

sudo rm -f /opt/local/bin/python*
sudo rm -f /opt/local/bin/pydoc*
sudo rm -f /usr/bin/python*
sudo rm -f /usr/bin/pydoc*
sudo rm -f /usr/local/bin/python*
sudo rm -f /usr/local/bin/pydoc*

# Install correct python version
PrimaryUrl="http://ci-files01-hki.intra.qt.io/input/mac/python-2.7.14-macosx10.6.pkg"
AltUrl="https://www.python.org/ftp/python/2.7.14/python-2.7.14-macosx10.6.pkg"
SHA1="fa2bb77243ad0cb611aa3295204fab403bb0fa09"
DestDir="/"

InstallPKGFromURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$DestDir"

/Library/Frameworks/Python.framework/Versions/2.7/bin/pip install virtualenv

echo "export PATH=/Library/Frameworks/Python.framework/Versions/2.7/bin/:\$PATH" >> ~/.bash_profile
echo "python2 = 2.7.14" >> ~/versions.txt
