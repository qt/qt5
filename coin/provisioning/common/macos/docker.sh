#!/usr/bin/env bash

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

set -ex

# Download and install the Docker Toolbox for macOS (Docker Compose and Docker Machine).
url="https://download.docker.com/mac/stable/DockerToolbox.pkg"
target_file="DockerToolbox.pkg"

if [ -x "$(command -v sha1sum)" ]
then
    # This part shall be used in CI environment only. The DownloadURL script needs sha1sum
    # which is not included in the default macOS system. In addition, the cached pkg can't
    # be downloaded out of the Qt internal network.
    case ${BASH_SOURCE[0]} in
        */macos/*) UNIX_PATH="${BASH_SOURCE[0]%/macos/*}/unix" ;;
        */*) UNIX_PATH="${BASH_SOURCE[0]%/*}/../unix" ;;
        *) UNIX_PATH="../unix" ;;
    esac

    source "$UNIX_PATH/DownloadURL.sh"
    url_cached="http://ci-files01-hki.intra.qt.io/input/windows/DockerToolbox.pkg"
    sha1="7196d2d30648d486978d29adb5837ff7876517c1"
    DownloadURL $url_cached $url $sha1 $target_file
else
    curl $url -o $target_file
fi
sudo installer -pkg $target_file -target /

# Start testserver provisioning
source "${BASH_SOURCE%/*}/docker_testserver.sh"
