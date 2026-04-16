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
#   - Note! This will only work with RHEL official RPMs - Not with internal repo clones
sudo subscription-manager release --set=10.0
sudo yum clean all

# Internal repo-clones must have exact release numbers to lock packages correctly
sudo tee "/etc/yum.repos.d/local.repo" > /dev/null <<EOC
[rhel-10-for-x86_64-baseos-rpms]
metadata_expire = 86400
baseurl = http://repo-clones-rhel10.ci.qt.io/10.0/rhel-10-for-x86_64-baseos-rpms
ui_repoid_vars = releasever basearch
name = Qt Red Hat Enterprise Linux 10 Base OS (RPMs)
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
enabled = 1
gpgcheck = 1

[rhel-10-for-x86_64-appstream-rpms]
metadata_expire = 86400
baseurl = http://repo-clones-rhel10.ci.qt.io/10.0/rhel-10-for-x86_64-appstream-rpms
ui_repoid_vars = releasever basearch
name = Qt Red Hat Enterprise Linux 10 Appstream (RPMs)
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
enabled = 1
gpgcheck = 1

[codeready-builder-for-rhel-10-x86_64-rpms]
metadata_expire = 86400
baseurl = http://repo-clones-rhel10.ci.qt.io/10.0/codeready-builder-for-rhel-10-x86_64-rpms
ui_repoid_vars = releasever basearch
name = Qt Red Hat Enterprise Linux Codeready Builder (RPMs)
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
enabled = 1
gpgcheck = 1
EOC

# Epel repo must have exact release number to lock packages correctly
sudo tee "/etc/yum.repos.d/epel-10.0.repo" > /dev/null <<EOC
[epel-10.0]
name = Extra Packages for Enterprise Linux 10.0 (Qt pinned)
baseurl = https://dl.fedoraproject.org/pub/epel/10.0/Everything/x86_64/
enabled = 1

gpgcheck = 1
repo_gpgcheck = 0
gpgkey = https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-10

metadata_expire = 86400
skip_if_unavailable = false
priority = 90
EOC
