#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2018 The Qt Company Ltd.
## Contact: http://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL21$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see http://www.qt.io/terms-conditions. For further
## information use the contact form at http://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 2.1 or version 3 as published by the Free
## Software Foundation and appearing in the file LICENSE.LGPLv21 and
## LICENSE.LGPLv3 included in the packaging of this file. Please review the
## following information to ensure the GNU Lesser General Public License
## requirements will be met: https://www.gnu.org/licenses/lgpl.html and
## http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
##
## As a special exception, The Qt Company gives you certain additional
## rights. These rights are described in The Qt Company LGPL Exception
## version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
##
## $QT_END_LICENSE$
##
#############################################################################

set -ex

source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"

version="17.0.1-6.20170307.wayland"
wayland_egl_rpm="mesa-libwayland-egl-$version.el7.x86_64.rpm"
wayland_egl_sha1="0a42fddd9a58c0bcd93efdaf84fd54b872f050d0"
wayland_egl_devel_rpm="mesa-libwayland-egl-devel-$version.el7.x86_64.rpm"
wayland_egl_devel_sha1="3ece8768e6bdd8603ce15d75f3b80895da038f15"
mirror1="http://ci-files01-hki.intra.qt.io/input/wayland"
mirror2=$mirror1

echo "Installing libwayland-egl development packages on RHEL"

# We're installing the packages with `--nodeps` because we've already installed
# the Wayland libraries, but not through the package manager.

DownloadURL $mirror1/$wayland_egl_rpm $mirror2/$wayland_egl_rpm $wayland_egl_sha1 /tmp/$wayland_egl_rpm
sudo rpm -i --nodeps /tmp/$wayland_egl_rpm
rm /tmp/$wayland_egl_rpm

DownloadURL $mirror1/$wayland_egl_devel_rpm $mirror2/$wayland_egl_devel_rpm $wayland_egl_devel_sha1 /tmp/$wayland_egl_devel_rpm
sudo rpm -i --nodeps /tmp/$wayland_egl_devel_rpm
rm /tmp/$wayland_egl_devel_rpm

echo "mesa-libwayland-egl = $version" >> ~/versions.txt
