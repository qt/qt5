#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2022 The Qt Company Ltd.
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

# shellcheck source=./../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"

# This script will install Docker which is needed by RTA

chip=$1

if [[ $chip == "amd64" ]]; then
    sha="158eae1d2f81cc8a0754d2ea3af8c6e6e555f69b"
else
    sha="6adf6cc8558af69296208b045187406a95b020bf"
fi

echo "Installing Docker for $chip chip"
urlOccifical="https://desktop.docker.com/mac/main/${chip}/Docker.dmg?utm_source=docker"
urlCache="http://ci-files01-hki.ci.qt.io/input/mac/Docker_${chip}.dmg"

DownloadURL $urlCache $urlOccifical $sha "/tmp/Docker_${chip}.dmg"

sudo hdiutil attach "/tmp/Docker_${chip}.dmg"
sudo /Volumes/Docker/Docker.app/Contents/MacOS/install --accept-license --user qt
sudo hdiutil detach /Volumes/Docker

# Add registry mirror for docker images
mkdir "$HOME/.docker"
sudo tee -a $HOME/.docker/daemon.json <<"EOF"
{
        "builder": { "gc": { "defaultKeepStorage": "20GB", "enabled": true } },
        "experimental": false,
        "features": { "buildkit": true },
        "registry-mirrors": ["http://repo-clones.ci.qt.io:5000"]
}
EOF
