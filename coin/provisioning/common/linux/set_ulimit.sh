#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2021 The Qt Company Ltd.
## Contact: https://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see https://www.qt.io/terms-conditions. For further
## information use the contact form at https://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 3 as published by the Free Software
## Foundation and appearing in the file LICENSE.LGPL3 included in the
## packaging of this file. Please review the following information to
## ensure the GNU Lesser General Public License version 3 requirements
## will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 2.0 or (at your option) the GNU General
## Public license version 3 or any later version approved by the KDE Free
## Qt Foundation. The licenses are as published by the Free Software
## Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
## included in the packaging of this file. Please review the following
## information to ensure the GNU General Public License requirements will
## be met: https://www.gnu.org/licenses/gpl-2.0.html and
## https://www.gnu.org/licenses/gpl-3.0.html.
##
## $QT_END_LICENSE$
##
#############################################################################

# This script will set ulimit size for open files
# Linker for Qt Webengine builds needs to open a multiple files. Without this it will hit the limit.

file="/etc/security/limits.conf"
file2="/etc/pam.d/common-session"
sudo sed -i '/End of file/d' $file
sudo tee -a $file <<"EOF"
* soft        nproc          4096
* hard        nproc          4096
* soft        nofile         4096
* hard        nofile         4096
root soft     nproc          4096
root hard     nproc          4096
root soft     nofile         4096
root hard     nofile         4096
# End of file
EOF

sudo sed -i '/end of pam-auth-update config/d' $file2
sudo tee -a $file2 <<"EOF"
session required        pam_limits.so
# end of pam-auth-update config
EOF

# This is required for UI login. Without this the ulimit will be 1024 during graphical login.
sudo tee -a /etc/systemd/user.conf <<"EOF"
DefaultLimitNOFILE=4096
EOF
