#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -ex

sudo sed -i "s#baseurl=.*#baseurl=http://repo-clones.ci.qt.io/repos/opensuse/distribution/leap/16.0/repo/oss/#g" /etc/zypp/repos.d/openSUSE:repo-oss.repo
sudo sed -i "s#baseurl=.*#baseurl=http://repo-clones.ci.qt.io/repos/opensuse/distribution/leap/16.0/repo/non-oss/#g" /etc/zypp/repos.d/openSUSE:repo-non-oss.repo
sudo sed -i "s#baseurl=.*#baseurl=http://repo-clones.ci.qt.io/repos/codecs.opensuse.org/openh264/openSUSE_Leap/#g" /etc/zypp/repos.d/openSUSE:repo-openh264.repo

sudo zypper lr -u
