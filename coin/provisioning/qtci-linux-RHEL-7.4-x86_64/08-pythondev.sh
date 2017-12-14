#!/bin/bash

#############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
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

source "${BASH_SOURCE%/*}/../common/DownloadURL.sh"

set -ex

packageEpel="epel-release-latest-7.noarch.rpm"
OfficialUrl="https://dl.fedoraproject.org/pub/epel/$packageEpel"
CachedUrl="http://ci-files01-hki.intra.qt.io/input/redhat/$packageEpel"
SHA1="5512b80e5b71f2370d8419fa16a0bc14c5edf854"

DownloadURL $OfficialUrl $CachedUrl $SHA1 ./$packageEpel
sudo rpm -Uvh $packageEpel
sudo rm -f $packageEpel

# install python3
sudo yum install -y python34-devel

# install pip3

packagePip="get-pip.py"
OfficialUrlPip="https://bootstrap.pypa.io/$packagePip"
CachedUrlPip="http://ci-files01-hki.intra.qt.io/input/redhat/$packagePip"
SHA1Pip="3d45cef22b043b2b333baa63abaa99544e9c031d"

DownloadURL $OfficialUrlPip $CachedUrlPip $SHA1Pip ./$packagePip
sudo python3 $packagePip
sudo rm -f $packagePip
sudo pip3 install virtualenv

