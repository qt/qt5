#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2021 The Qt Company Ltd.
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

# This script installs QNX 7.

set -ex

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

DownloadAndExtract () {
    url=$1
    sha=$2
    file=$3
    folder=$4

    DownloadURL "$url" "$url" "$sha" "$file"
    sudo tar -C $folder -Jxf $file

    rm -rf $file
}

aarch64le_toolchain="${BASH_SOURCE%/*}/../shared/cmake_toolchain_files/qnx-toolchain-aarch64le.cmake"
armv7le_toolchain="${BASH_SOURCE%/*}/../shared/cmake_toolchain_files/qnx-toolchain-armv7le.cmake"
x8664_toolchain="${BASH_SOURCE%/*}/../shared/cmake_toolchain_files/qnx-toolchain-x8664.cmake"
QNX_qemu_bld_files_dir="${BASH_SOURCE%/*}/qnx_qemu_build_files/"

targetFolder="/opt/"
folderName="qnx710"
targetPath="$targetFolder$folderName"
qemuTargetPath="$HOME/QNX"
qemuIpAddress="172.31.1.10"
qemuNetwork="172.31.1.1"
qemuSSHuser="root"
qemuSSHurl="$qemuSSHuser@$qemuIpAddress"
qemuLDpath="/proc/boot:/system/lib:/system/lib/dll:/home/qt/work/install/target/lib"

if [ ! -d "$targetFolder" ]; then
    mkdir -p $targetFolder
fi

# QNX SDP
sourceFile="http://ci-files01-hki.intra.qt.io/input/qnx/qnx710-windows-linux-20220405.tar.xz"
targetFile="qnx710.tar.xz"
sha1="134af2e0f75d7b7c516f824fafee265b89e51d48"
DownloadAndExtract "$sourceFile" "$sha1" "$targetFile" "$targetFolder"

sudo cp $aarch64le_toolchain $targetPath
sudo cp $armv7le_toolchain $targetPath
sudo cp $x8664_toolchain $targetPath
cp -R $QNX_qemu_bld_files_dir $qemuTargetPath
# fc-match tool is missing from QNX SDP and tst_qfont requires it to work corretly
# Download code-only package from https://www.iana.org/time-zones and follow README
# to build tools for QNX x86_64. If need to build new tool create new qnx_qemu_utils
# package which contains it and update required info below
sourceFile="http://ci-files01-hki.intra.qt.io/input/qnx/qnx_qemu_utils_20211208.tar.xz"
targetFile="qnx_qemu_utils.tar.xz"
targetFolder="$qemuTargetPath/local/misc_files"
sha1="7653f5d50f61f1591d7785c3ec261228ecc9dd22"
if [ ! -d "$targetFolder" ]; then
    mkdir -p $targetFolder
fi
DownloadAndExtract "$sourceFile" "$sha1" "$targetFile" "$targetFolder"

# Add ssl certificates. Expects Ubuntu 20.04 LTS with ca-certificates package installed
cp -R /usr/share/ca-certificates "$targetFolder"
mkdir -p "$targetFolder/etc/ssl/certs"
cp -PR /etc/ssl/certs/* "$targetFolder/etc/ssl/certs"

sudo chown -R qt:users "$targetPath"

# Verify that we have last files in tars
if [ ! -f $targetPath/qnxsdp-env.sh ] || [ ! -f $targetPath/qnx-toolchain-x8664.cmake ]
then
    echo "QNX toolchain installation failed!"
    exit -1
fi

# Set env variables
SetEnvVar "QNX_710" "$targetPath"
SetEnvVar "QNX_QEMU" "$qemuTargetPath"
SetEnvVar "QNX_QEMU_IPADDR" "$qemuIpAddress"
SetEnvVar "QNX_QEMU_SSH" "$qemuSSHurl"
SetEnvVar "QNX_QEMU_LD_LIBRARY_PATH" "$qemuLDpath"

echo "QNX SDP = 7.1.0" >> ~/versions.txt
