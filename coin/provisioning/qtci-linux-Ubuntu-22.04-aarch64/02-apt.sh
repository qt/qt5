#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# Install required packages with APT

# shellcheck source=../common/linux/apt_wait_loop.sh
source "${BASH_SOURCE%/*}/../common/linux/apt_wait_loop.sh"

echo "Disabling auto update"
sudo sed -i 's/APT::Periodic::Update-Package-Lists "1";/APT::Periodic::Update-Package-Lists "0";/' /etc/apt/apt.conf.d/10periodic
for service in apt-daily.timer apt-daily-upgrade.timer apt-daily.service apt-daily-upgrade.service; do
    sudo systemctl stop $service
    sudo systemctl disable $service
done

function set_internal_repo {

    # Stop fetching the dep-11 metadata, since our mirrors do not handle them well
    sudo mv /etc/apt/apt.conf.d/50appstream{,.disabled}

    sudo tee "/etc/apt/sources.list" > /dev/null <<-EOC
    deb [arch=aarch64] http://repo-clones.ci.qt.io/apt-mirror/mirror/ubuntu/ jammy main restricted universe multiverse
    deb [arch=aarch64 http://repo-clones.ci.qt.io/apt-mirror/mirror/ubuntu/ jammy-updates main restricted universe multiverse
    deb [arch=aarch64] http://repo-clones.ci.qt.io/apt-mirror/mirror/ubuntu/ jammy-backports main restricted universe
    deb [arch=aarch64] http://repo-clones.ci.qt.io/apt-mirror/mirror/ubuntu/ jammy-security main restricted universe multiverse
EOC
}

#repo-clones not set up for aarch64 yet
#(ping -c 3 repo-clones.ci.qt.io && set_internal_repo) || echo "Internal package repository not found. Using public repositories."

# Make sure needed ca-certificates are available
installPackages+=(ca-certificates)

## Tools
# Git is not needed by builds themselves, but is nice to have
# immediately as one starts debugging
installPackages+=(git)

# 7zip is a needed decompressing tool
installPackages+=(p7zip-full)

# Packages needed for RTA and Squish
installPackages+=(default-jdk)
installPackages+=(gcc)
installPackages+=(curl)
installPackages+=(libicu-dev)
installPackages+=(python3-dev)
installPackages+=(python3-pip)
installPackages+=(python3-venv)
installPackages+=(virtualenv)
# For mounting ci-files01 for Squish
installPackages+=(nfs-common)

echo "Running update for apt"
waitLoop
sudo apt-get update
echo "Installing packages"
waitLoop
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y -o DPkg::Lock::Timeout=300 install "${installPackages[@]}"

source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"
# SetEnvVar "PATH" "/usr/lib/nodejs-mozilla/bin:\$PATH"

OpenSSLVersion="$(openssl version |cut -b 9-14)"
echo "OpenSSL = $OpenSSLVersion" >> ~/versions.txt

