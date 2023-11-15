#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

echo "set WritePreparedUpdates=false" | sudo tee -a /etc/PackageKit/PackageKit.conf
sudo systemctl stop packagekit
sudo systemctl disable packagekit
sudo yum -y remove PackageKit gnome-software

sudo subscription-manager config --rhsm.manage_repos=1
sudo subscription-manager refresh

# List available RHEL versions and bind with correct one
sudo subscription-manager release --list
sudo subscription-manager release --set=8.4
sudo yum clean all

# sudo yum config-manager --enable 'rhceph-4-tools-for-rhel-8-x86_64-rpms'
sudo yum config-manager --enable 'codeready-builder-for-rhel-8-x86_64-rpms'
sudo yum config-manager --enable 'rhel-8-for-x86_64-baseos-rpms'
sudo yum config-manager --enable 'rhel-8-for-x86_64-appstream-rpms'
# Epel is required for 'double-conversion-devel', 'libsqlite3x' and 'p7zip'
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

sudo yum clean all
# As well as this fetching the repository data, we also get a printout of the used repos
sudo yum repolist
