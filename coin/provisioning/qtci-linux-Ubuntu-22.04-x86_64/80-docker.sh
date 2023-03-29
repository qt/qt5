#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -e

PROVISIONING_DIR="$(dirname "$0")/../"
# shellcheck source=../common/unix/common.sourced.sh
source "$PROVISIONING_DIR"/common/unix/common.sourced.sh
# shellcheck source=../common/unix/DownloadURL.sh
source "$PROVISIONING_DIR"/common/unix/DownloadURL.sh

localRepo=http://ci-files01-hki.ci.qt.io/input/docker
# upstreamRepo=https://download.docker.com/linux/ubuntu/dists/bionic/pool/stable/amd64
upstreamRepo=https://download.docker.com/linux/ubuntu/dists/jammy/pool/stable/amd64
echo '
    429078ba4948395ab88cd06c6ef49ea37c965273 containerd.io_1.6.4-1_amd64.deb
    5ce7508bb9d478dd9fe8ed9869e8ab0eed0355d9 docker-ce_20.10.15_3-0_ubuntu-jammy_amd64.deb
    445e81ad86c37d796de64644da4f9b3d6c6df913 docker-ce-cli_20.10.15_3-0_ubuntu-jammy_amd64.deb
' \
    | xargs -n2 | while read -r sha f
do
    DownloadURL "$localRepo/$f" "$upstreamRepo/$f" "$sha"
done

sudo apt-get -y install  ./containerd.io_*.deb ./docker-ce_*.deb ./docker-ce-cli_*.deb
rm -f                    ./containerd.io_*.deb ./docker-ce_*.deb ./docker-ce-cli_*.deb

sudo usermod -a -G docker "$USER"
sudo docker --version

# Download and install the docker-compose extension from https://github.com/docker/compose/releases
f=docker-compose-$(uname -s)-$(uname -m)
DownloadURL  \
    "$localRepo/$f-1.24.1"  \
    "https://github.com/docker/compose/releases/download/1.24.1/$f" \
    cfb3439956216b1248308141f7193776fcf4b9c9b49cbbe2fb07885678e2bb8a
sudo install -m 755 ./docker-compose* /usr/local/bin/docker-compose
sudo docker-compose --version
rm ./docker-compose*

# Install Avahi to discover Docker containers in the test network
sudo apt-get install avahi-daemon -y

# Add registry mirror for docker images
sudo tee -a /etc/docker/daemon.json <<"EOF"
{
  "registry-mirrors": ["http://repo-clones.ci.qt.io:5000"]
}
EOF

echo "Restart Docker"
sudo systemctl daemon-reload
sudo systemctl restart docker

# Start testserver provisioning
sudo "$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")/../common/shared/testserver/docker_testserver.sh"

