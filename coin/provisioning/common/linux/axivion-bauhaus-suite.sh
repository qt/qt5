#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2023 The Qt Company Ltd.
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

# This script installs Axivion Bauhaus Suite tool.

set -ex

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
# source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

DownloadAndExtract () {
    url=$1
    sha=$2
    file=$3

    DownloadURL "$url" "$url" "$sha" "$file"
    tar -xzvf $file

    rm -rf $file
}


# Axivion Bauhaus Suite
sourceFile="http://ci-files01-hki.ci.qt.io/input/axivion/bauhaus-suite-7_6_0-wavefront-2023-03-16-x86_64-gnu_linux.tar.gz"
targetFile="bauhaus-suite-7_6_0-wavefront-2023-03-16-x86_64-gnu_linux.tar.gz"
sha1="20bfa8872b90ff11394098a833d536229425535e"
cd $HOME
DownloadAndExtract "$sourceFile" "$sha1" "$targetFile" "$HOME"

mkdir $HOME/.bauhaus
cd "$HOME/.bauhaus"
wget http://ci-files01-hki.ci.qt.io/input/axivion/Qt_Evaluation_20231231.key
cd $HOME

#Axivion configuration
configurationFile="http://ci-files01-hki.ci.qt.io/input/axivion/axivion_config.tar.gz"
configurationTargetFile="axivion_config.tar.gz"
configSha1="f3aa53f253fa00c7f3fa64e9fe55aa7f93bc5377"
DownloadAndExtract "$configurationFile" "$configSha1" "$configurationTargetFile" "$HOME"

echo "Axivion Bauhaus Suite = 7.6.0_wavefront-2022-03-16" >> ~/versions.txt
