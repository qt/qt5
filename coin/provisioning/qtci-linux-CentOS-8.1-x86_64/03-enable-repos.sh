#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2020 The Qt Company Ltd.
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

sudo rm -f /etc/yum.repos.d/*.repo

sudo tee "/etc/yum.repos.d/local.repo" > /dev/null <<EOC
[BaseOS]
name = Qt Centos-8 - Base
metadata_expire = 86400
baseurl = http://repo-clones.ci.qt.io/repos/centos/8/BaseOS/x86_64/os/
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
enabled = 1
gpgcheck = 1

[AppStream]
name = Qt Centos-8 - AppStream
metadata_expire = 86400
baseurl = http://repo-clones.ci.qt.io/repos/centos/8/AppStream/x86_64/os/
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
enabled = 1
gpgcheck = 1

[PowerTools]
name = Qt Centos-8 - PowerTools
metadata_expire = 86400
baseurl = http://repo-clones.ci.qt.io/repos/centos/8/PowerTools/x86_64/os/
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
enabled = 1
gpgcheck = 1

[epel]
name = Qt Centos-8 - EPEL
metadata_expire = 86400
baseurl = http://repo-clones.ci.qt.io/repos/centos/epel/8/Everything/x86_64/
enabled = 1
gpgcheck = 1
gpgkey = http://repo-clones.ci.qt.io/repos/centos/epel/RPM-GPG-KEY-EPEL-8

[epel-playground]
name = Qt Centos-8 - EPEL Playground
metadata_expire = 86400
baseurl = http://repo-clones.ci.qt.io/repos/centos/epel/playground/8/Everything/x86_64/os/
enabled = 1
gpgcheck = 1
gpgkey = http://repo-clones.ci.qt.io/repos/centos/epel/RPM-GPG-KEY-EPEL-8
EOC

sudo yum clean all
# As well as this fetching the repository data, we also get a printout of the used repos
sudo yum repolist
