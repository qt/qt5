#!/usr/bin/env bash
#############################################################################
##
## Copyright (C) 2022 The Qt Company Ltd.
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

# This script will install up-to-date google Chrome needed for Webassembly auto tests.

# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"

# Webassembly auto tests run requires latest Chrome. Let's use the latest stable one which means we can't cache this
sudo zypper ar http://dl.google.com/linux/chrome/rpm/stable/x86_64 Google-Chrome

# Add the Google public signing key
externalUrl="https://dl.google.com/linux/linux_signing_key.pub"
Download "$externalUrl" "/tmp/linux_signing_key.pub"
sudo rpm --import /tmp/linux_signing_key.pub

# Update the repo cache of zypper and install Chrome
sudo zypper ref -f
sudo zypper -nq install --no-confirm google-chrome-stable

# Install Chromedriver Chromium
sudo zypper -nq install chromedriver

