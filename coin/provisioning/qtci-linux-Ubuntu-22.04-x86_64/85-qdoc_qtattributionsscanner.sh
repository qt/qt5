#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2022 The Qt Company Ltd.
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

# Provisions qdoc and qtattributionsscanner binaries; these are used for
# documentation testing without the need for a dependency to qttools.

set -e

# shellcheck source=./check_and_set_proxy.sh
"${BASH_SOURCE%/*}/../common/unix/check_and_set_proxy.sh"
# shellcheck source=./DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"
version="22ac5ee7e6e9e80c34ffe3616b1ac461e9a552cd"
sha1="32084b2e3fd63b715d3eaee5545164e6781d52ec"
url="https://download.qt.io/development_releases/prebuilt/qdoc/qt/qdoc-qtattributionsscanner_${version//\./}-based-linux-Ubuntu22.04-gcc11.4-x86_64.7z"
url_cached="http://ci-files01-hki.ci.qt.io/input/qdoc/qt/qdoc-qtattributionsscanner_${version//\./}-based-linux-Ubuntu22.04-gcc11.4-x86_64.7z"

zip="/tmp/qdoc-qtattributionsscanner.7z"
destination="/opt/qt-doctools"

sudo mkdir -p $destination
sudo chmod 755 $destination
DownloadURL $url_cached $url $sha1 $zip
if command -v 7zr &> /dev/null; then
    sudo 7zr x $zip -o$destination/
else
    sudo 7z x $zip -o$destination/
fi
sudo chown -R qt:users $destination
rm -rf $zip

echo -e "qdoc = $version\nqtattributionsscanner = $version" >> ~/versions.txt
