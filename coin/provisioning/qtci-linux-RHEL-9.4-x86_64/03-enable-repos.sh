#!/usr/bin/env bash
# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

echo "set WritePreparedUpdates=false" | sudo tee -a /etc/PackageKit/PackageKit.conf
sudo systemctl stop packagekit
sudo systemctl mask --now packagekit
while sudo fuser /usr/libexec/packagekitd >/dev/null 2>&1; do
    echo "Waiting for PackageKit to finish..."
    sleep 1
    sudo systemctl stop packagekit
done
sudo yum -y remove PackageKit gnome-software

sudo subscription-manager config --rhsm.manage_repos=0
sudo subscription-manager refresh

# List available RHEL versions and bind with correct one
sudo subscription-manager release --list
sudo subscription-manager release --set=9.4
sudo yum clean all

sudo tee "/etc/yum.repos.d/local.repo" > /dev/null <<EOC
[rhel-9-for-x86_64-baseos-rpms]
metadata_expire = 86400
baseurl = http://repo-clones-rhel9.ci.qt.io/rhel-9-for-x86_64-baseos-rpms
ui_repoid_vars = releasever basearch
name = Qt Red Hat Enterprise Linux 9 Base OS (RPMs)
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
enabled = 1
gpgcheck = 1

[rhel-9-for-x86_64-appstream-rpms]
metadata_expire = 86400
baseurl = http://repo-clones-rhel9.ci.qt.io/rhel-9-for-x86_64-appstream-rpms
ui_repoid_vars = releasever basearch
name = Qt Red Hat Enterprise Linux 9 Appstream (RPMs)
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
enabled = 1
gpgcheck = 1

[codeready-builder-for-rhel-9-x86_64-rpms]
metadata_expire = 86400
baseurl = http://repo-clones-rhel9.ci.qt.io/codeready-builder-for-rhel-9-x86_64-rpms
ui_repoid_vars = releasever basearch
name = Qt Red Hat Enterprise Linux Codeready Builder (RPMs)
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
enabled = 1
gpgcheck = 1
EOC

# Epel is required for 'double-conversion-devel', 'libsqlite3x' and 'p7zip'
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

sudo yum clean all
# As well as this fetching the repository data, we also get a printout of the used repos
sudo yum repolist
