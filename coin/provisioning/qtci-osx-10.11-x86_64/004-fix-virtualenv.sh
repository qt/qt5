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
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"
# macOS 10.11 template doesn't have working virtualenv installation.
# To fix that, we first have to install pip to install virtualenv
# Install pip
urlCache="http://ci-files01-hki.intra.qt.io/input/utils/get-pip.py"
urlAlt="https://bootstrap.pypa.io/get-pip.py"
sha1="3d45cef22b043b2b333baa63abaa99544e9c031d"
DownloadURL $urlCache $urlAlt $sha1 get-pip.py

sudo python get-pip.py
rm get-pip.py

# remove possible link pointing to broken virtualenv
sudo rm -f /opt/local/bin/virtualenv
sudo pip install virtualenv

# make sure it is now in PATH
which virtualenv
if [[ $? -ne 0 ]]; then
    exit 1
fi
