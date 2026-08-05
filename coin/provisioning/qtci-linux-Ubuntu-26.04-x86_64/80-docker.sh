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
#upstreamRepo=https://download.docker.com/linux/ubuntu/dists/jammy/pool/stable/amd64
#upstreamRepo=https://download.docker.com/linux/ubuntu/dists/noble/pool/stable/amd64
upstreamRepo=https://download.docker.com/linux/ubuntu/dists/resolute/pool/stable/amd64
echo '
    40e42f4d1f868c68e3bdb19d8e1e82872e0328a7 containerd.io_2.3.3-1~ubuntu.26.04~resolute_amd64.deb
    14cedb6de2737bc165c0460ad86604bc510aca4f docker-ce_29.7.2-1~ubuntu.26.04~resolute_amd64.deb
    36c54832eb62cf9af38b5101276b36f145abbd07 docker-ce-cli_29.7.2-1~ubuntu.26.04~resolute_amd64.deb
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

