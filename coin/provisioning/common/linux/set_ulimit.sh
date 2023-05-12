#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

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
