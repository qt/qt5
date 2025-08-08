#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

sudo sed -i "s#baseurl=.*#baseurl=http://repo-clones.ci.qt.io/repos/opensuse/distribution/leap/15.6/repo/oss/#g" /etc/zypp/repos.d/repo-oss.repo
sudo sed -i "s#baseurl=.*#baseurl=http://repo-clones.ci.qt.io/repos/opensuse/distribution/leap/15.6/repo/non-oss/#g" /etc/zypp/repos.d/repo-non-oss.repo
sudo sed -i "s#baseurl=.*#baseurl=http://repo-clones.ci.qt.io/repos/opensuse/update/leap/15.6/oss/#g" /etc/zypp/repos.d/repo-update.repo
sudo sed -i "s#baseurl=.*#baseurl=http://repo-clones.ci.qt.io/repos/opensuse/update/leap/15.6/non-oss/#g" /etc/zypp/repos.d/repo-update-non-oss.repo
sudo sed -i "s#baseurl=.*#baseurl=http://repo-clones.ci.qt.io/repos/opensuse/update/leap/15.6/backports/#g" /etc/zypp/repos.d/repo-backports-update.repo
sudo sed -i "s#baseurl=.*#baseurl=http://repo-clones.ci.qt.io/repos/opensuse/update/leap/15.6/sle/#g" /etc/zypp/repos.d/repo-sle-update.repo
sudo sed -i "s#baseurl=.*#baseurl=http://repo-clones.ci.qt.io/repos/codecs.opensuse.org/openh264/openSUSE_Leap/#g" /etc/zypp/repos.d/repo-openh264.repo

sudo zypper lr -u
