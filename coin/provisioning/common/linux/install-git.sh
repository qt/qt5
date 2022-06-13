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

# This script install git from sources.
# Requires GCC and Perl to be in PATH.
set -ex

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

version="2.36.1"
officialUrl="https://github.com/git/git/archive/refs/tags/v$version.tar.gz"
cachedUrl="http://ci-files01-hki.intra.qt.io/input/git/git-$version.tar.gz"
targetFile="/tmp/git-$version.tar.gz"
sha="a17c11da2968f280a13832d97f48e9039edac354"
DownloadURL "$cachedUrl" "$officialUrl" "$sha" "$targetFile"
sourceDir="/tmp/git-$version-source"
mkdir $sourceDir
tar -xzf "$targetFile" -C $sourceDir

cd "$sourceDir/git-$version"
installDir="$HOME/git"
make configure
./configure --prefix=$installDir
make all
sudo make install

SetEnvVar "PATH" "\"$installDir/bin:\$PATH\""

$installDir/bin/git --version
