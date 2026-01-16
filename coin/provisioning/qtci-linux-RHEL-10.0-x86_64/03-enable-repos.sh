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

# Do not update Tier 1 via GUI without using this same --set
#   - To avoid System to have newer packages than RPMS which will cause update issues
sudo subscription-manager release --set=10.0
sudo yum clean all

sudo tee "/etc/yum.repos.d/local.repo" > /dev/null <<EOC
[rhel-10-for-x86_64-baseos-rpms]
metadata_expire = 86400
baseurl = http://repo-clones-rhel10.ci.qt.io/rhel-10-for-x86_64-baseos-rpms
ui_repoid_vars = releasever basearch
name = Qt Red Hat Enterprise Linux 10 Base OS (RPMs)
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
enabled = 1
gpgcheck = 1

[rhel-10-for-x86_64-appstream-rpms]
metadata_expire = 86400
baseurl = http://repo-clones-rhel10.ci.qt.io/rhel-10-for-x86_64-appstream-rpms
ui_repoid_vars = releasever basearch
name = Qt Red Hat Enterprise Linux 10 Appstream (RPMs)
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
enabled = 1
gpgcheck = 1

[codeready-builder-for-rhel-10-x86_64-rpms]
metadata_expire = 86400
baseurl = http://repo-clones-rhel10.ci.qt.io/codeready-builder-for-rhel-10-x86_64-rpms
ui_repoid_vars = releasever basearch
name = Qt Red Hat Enterprise Linux Codeready Builder (RPMs)
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
enabled = 1
gpgcheck = 1
EOC

# Epel is required for 'double-conversion-devel', 'libsqlite3x' and 'p7zip'
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm

sudo yum clean all
# As well as this fetching the repository data, we also get a printout of the used repos
sudo yum repolist
