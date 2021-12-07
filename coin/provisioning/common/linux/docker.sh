#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
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

set -e


PROVISIONING_DIR="$(dirname "$0")/../../"
. "$PROVISIONING_DIR"/common/unix/common.sourced.sh
. "$PROVISIONING_DIR"/common/unix/DownloadURL.sh


localRepo=http://ci-files01-hki.intra.qt.io/input/docker
upstreamRepo=https://download.docker.com/linux/ubuntu/dists/bionic/pool/stable/amd64

echo '
    f4c941807310e3fa470dddfb068d599174a3daec containerd.io_1.2.10-3_amd64.deb
    ee640d9258fd4d3f4c7017ab2a71da63cbbead55 docker-ce_19.03.4~3-0~ubuntu-bionic_amd64.deb
    09402bf5dac40f0c50f1071b17f38f6584a42ad1 docker-ce-cli_19.03.4~3-0~ubuntu-bionic_amd64.deb
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
DownloadURL  \
    $localRepo/$f-1.24.1  \
    https://github.com/docker/compose/releases/download/1.24.1/$f \
    cfb3439956216b1248308141f7193776fcf4b9c9b49cbbe2fb07885678e2bb8a
sudo install -m 755 ./docker-compose* /usr/local/bin/docker-compose
sudo docker-compose --version
rm ./docker-compose*

# Install Avahi to discover Docker containers in the test network
sudo apt-get install avahi-daemon -y

# Start testserver provisioning
sudo "$(readlink -f $(dirname ${BASH_SOURCE[0]}))/../shared/testserver/docker_testserver.sh"
