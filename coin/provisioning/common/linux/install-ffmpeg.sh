#!/usr/bin/env bash

############################################################################
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

# This script will build and install FFmpeg static libs
set -ex

# shellcheck source=../unix/InstallFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../unix/InstallFromCompressedFileFromURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

ffmpeg_config_options=$(cat "${BASH_SOURCE%/*}/../shared/ffmpeg_config_options.txt")

sudo apt install yasm

version="n5.0"
ffmpeg_name="FFmpeg-$version"

url_cached="http://ci-files01-hki.intra.qt.io/input/ffmpeg/$version.tar.gz"
url_public="https://github.com/FFmpeg/FFmpeg/archive/refs/tags/$version.tar.gz"
sha1="1a979876463fd81e481d53ceb3cc117f0fce8521"

target_folder="$HOME"
app_prefix=""

InstallFromCompressedFileFromURL "$url_cached" "$url_public" "$sha1" "$target_folder" "$app_prefix"

mkdir -p "$target_folder/$ffmpeg_name/build"
pushd "$target_folder/$ffmpeg_name/build"
../configure $ffmpeg_config_options --prefix=installed
make install -j
popd

SetEnvVar "FFMPEG_DIR" "$target_folder/$ffmpeg_name/build/installed"
