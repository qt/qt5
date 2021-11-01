#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2021 The Qt Company Ltd.
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

# Will install homebrew package manager for macOS.
#     WARNING: Requires commandlinetools


set -e

. "$(dirname "$0")"/../common/unix/DownloadURL.sh


DownloadURL  \
    http://ci-files01-hki.intra.qt.io/input/mac/homebrew/a822f0d0f1838c07e86b356fcd2bf93c7a11c2aa/install.sh  \
    https://raw.githubusercontent.com/Homebrew/install/c744a716f9845988d01e6e238eee7117b8c366c9/install  \
    3210da71e12a699ab3bba43910a6d5fc64b92000  \
    /tmp/homebrew_install.sh

DownloadURL "http://ci-files01-hki.intra.qt.io/input/semisecure/sign/pw" "http://ci-files01-hki.intra.qt.io/input/semisecure/sign/pw" "aae58d00d0a1b179a09f21cfc67f9d16fb95ff36" "/Users/qt/pw"
{ pw=$(cat "/Users/qt/pw"); } 2> /dev/null
sudo chmod 755 /tmp/homebrew_install.sh
{ (echo $pw | /tmp/homebrew_install.sh); } 2> /dev/null
rm -f "/Users/qt/pw"

# No need to manually do `brew update`, the homebrew installer script does it.
### brew update

