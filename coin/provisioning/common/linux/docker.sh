#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

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
