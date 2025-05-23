#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs QNX 8.

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
    sudo tar -C "$folder" -Jxf "$file"

    rm -rf "$file"
}

aarch64le_toolchain="${BASH_SOURCE%/*}/../shared/cmake_toolchain_files/qnx-toolchain-aarch64le.cmake"
armv7le_toolchain="${BASH_SOURCE%/*}/../shared/cmake_toolchain_files/qnx-toolchain-armv7le.cmake"
x8664_toolchain="${BASH_SOURCE%/*}/../shared/cmake_toolchain_files/qnx-toolchain-x8664.cmake"
QNX_qemu_bld_files_dir="${BASH_SOURCE%/*}/qnx_qemu_build_files/800/"

targetFolder="/opt/"
folderName="qnx800"
targetPath="$targetFolder$folderName"
qemuTargetPath="$HOME/QNX800"
qemuIpAddress="172.31.1.10"
export qemuNetwork="172.31.1.1"
qemuSSHuser="root"
qemuSSHurl="$qemuSSHuser@$qemuIpAddress"
qemuLDpath="/proc/boot:/system/lib:/system/lib/dll:/home/qt/work/install/target/lib"

if [ ! -d "$targetFolder" ]; then
    mkdir -p "$targetFolder"
fi

# QNX SDP
sourceFile="http://ci-files01-hki.ci.qt.io/input/qnx/qnx800-windows-linux-20250612.tar.xz"
targetFile="qnx800.tar.xz"
sha1="d7ca20be6867b569067a17e8b3fa633c7eadad89"
DownloadAndExtract "$sourceFile" "$sha1" "$targetFile" "$targetFolder"

sudo cp "$aarch64le_toolchain" "$targetPath"
sudo cp "$armv7le_toolchain" "$targetPath"
sudo cp "$x8664_toolchain" "$targetPath"
cp -R "$QNX_qemu_bld_files_dir" "$qemuTargetPath"
# fc-match tool is missing from QNX SDP and tst_qfont requires it to work corretly
# Download code-only package from https://www.iana.org/time-zones and follow README
# to build tools for QNX x86_64. If need to build new tool create new qnx_qemu_utils
# package which contains it and update required info below
sourceFile="http://ci-files01-hki.ci.qt.io/input/qnx/qnx_qemu_utils_20211208.tar.xz"
targetFile="qnx_qemu_utils.tar.xz"
targetFolder="$qemuTargetPath/local/misc_files"
sha1="7653f5d50f61f1591d7785c3ec261228ecc9dd22"

mkdir -p "$targetFolder"

DownloadAndExtract "$sourceFile" "$sha1" "$targetFile" "$targetFolder"

# Add ssl certificates. Expects Ubuntu 22.04 LTS with ca-certificates package installed
cp -R /usr/share/ca-certificates "$targetFolder"
mkdir -p "$targetFolder/etc/ssl/certs"
cp -PR /etc/ssl/certs/* "$targetFolder/etc/ssl/certs"

sudo chown -R qt:users "$targetPath"

# Verify that we have last files in tars
if [ ! -f "$targetPath/qnxsdp-env.sh" ] || [ ! -f "$targetPath/qnx-toolchain-x8664.cmake" ]
then
    echo "QNX toolchain installation failed!"
    exit 1
fi

# Target folder has been renamed on QNX8.0 SDP. Link is created to simplify environment
# setting at qtBase
sudo ln -s $targetPath/target/qnx $targetPath/target/qnx7

# Set env variables
SetEnvVar "QNX_800" "$targetPath"
SetEnvVar "QNX_800_QEMU" "$qemuTargetPath"
# These are common defines with QNX710
SetEnvVar "QNX_QEMU_IPADDR" "$qemuIpAddress"
SetEnvVar "QNX_QEMU_SSH" "$qemuSSHurl"
SetEnvVar "QNX_QEMU_LD_LIBRARY_PATH" "$qemuLDpath"


echo "QNX SDP = 8.0.0" >> ~/versions.txt
