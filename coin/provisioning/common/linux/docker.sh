#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2023 The Qt Company Ltd.
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

set -e


PROVISIONING_DIR="$(dirname "$0")/../../"
. "$PROVISIONING_DIR"/common/unix/common.sourced.sh
. "$PROVISIONING_DIR"/common/unix/DownloadURL.sh


localRepo=http://ci-files01-hki.intra.qt.io/input/docker
upstreamRepo=https://download.docker.com/linux/ubuntu/dists/focal/pool/stable/amd64/

echo '
    2666840157bab3b77a850236fbf323c423fb564a containerd.io_1.6.9-1_amd64.deb
    ec6a1ad99b19b6a674349fb13bcc10d62c54c404 docker-ce_23.0.0-1~ubuntu.20.04~focal_amd64.deb
    130774916fa7e2c9997b8fcb4e7696a343f12fb0 docker-ce-cli_23.0.0-1~ubuntu.20.04~focal_amd64.deb
' \
    | xargs -n2 | while read  sha f
do
    DownloadURL  $localRepo/$f  $upstreamRepo/$f  $sha
done

sudo apt-get -y install  ./containerd.io_*.deb ./docker-ce_*.deb ./docker-ce-cli_*.deb
rm -f                    ./containerd.io_*.deb ./docker-ce_*.deb ./docker-ce-cli_*.deb

sudo usermod -a -G docker $USER
sudo docker --version

# Download and install the docker-compose extension from https://github.com/docker/compose/releases
f=docker-compose-$(uname -s)-$(uname -m)
dockerComposeVersion="v2.15.1"
DownloadURL  \
    $localRepo/$f-${dockerComposeVersion}  \
    https://github.com/docker/compose/releases/download/${dockerComposeVersion}/$f \
    bcfd9ea51dee4c19dccdfaeef0e7956ef68bf14f3d175933742061a7271ef0f5
sudo install -m 755 ./docker-compose* /usr/local/bin/docker-compose
sudo docker-compose --version
rm ./docker-compose*

# Install Avahi to discover Docker containers in the test network
sudo apt-get install avahi-daemon -y

# Start testserver provisioning
sudo "$(readlink -f $(dirname ${BASH_SOURCE[0]}))/../shared/testserver/docker_testserver.sh"
