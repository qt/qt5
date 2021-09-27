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

# Provisions qdoc and qtattributionsscanner binaries; these are used for
# documentation testing without the need for a dependency to qttools.

set -e

# shellcheck source=./check_and_set_proxy.sh
"${BASH_SOURCE%/*}/../common/unix/check_and_set_proxy.sh"
# shellcheck source=./DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"

version="d2fc6facca4ddf889bb4f5d1f60592fd228d246e"
sha1="8c2f42eaa520dc2b26072233fe000bb7b050e9c8"
url="https://download.qt.io/development_releases/prebuilt/qdoc/qt/qdoc-qtattributionsscanner_${version//\./}-based-linux-Ubuntu20.04-gcc9.3-x86_64.7z"
url_cached="http://ci-files01-hki.intra.qt.io/input/qdoc/qt/qdoc-qtattributionsscanner_${version//\./}-based-linux-Ubuntu20.04-gcc9.3-x86_64.7z"

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
