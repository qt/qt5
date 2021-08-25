#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2021 The Qt Company Ltd.
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
