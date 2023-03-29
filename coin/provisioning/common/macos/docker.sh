#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

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

DownloadURL "$urlCache" "$urlOccifical" "$sha" "/tmp/Docker_${chip}.dmg"

sudo hdiutil attach "/tmp/Docker_${chip}.dmg"
sudo /Volumes/Docker/Docker.app/Contents/MacOS/install --accept-license --user qt
sudo hdiutil detach /Volumes/Docker

# Add registry mirror for docker images
mkdir "$HOME/.docker"
sudo tee -a "$HOME/.docker/daemon.json" <<"EOF"
{
        "builder": { "gc": { "defaultKeepStorage": "20GB", "enabled": true } },
        "experimental": false,
        "features": { "buildkit": true },
        "registry-mirrors": ["http://repo-clones.ci.qt.io:5000"]
}
EOF
