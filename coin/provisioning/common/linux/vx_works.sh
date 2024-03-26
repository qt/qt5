#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs vxworks libs and toolchain.

set -ex

# shellcheck source=../unix/InstallFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../unix/InstallFromCompressedFileFromURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

VXWORKS_VER="23_09"
######### VXworks libs #########
# Installs to /opt/vxworks
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/vxworks/vxworks_no_source_patched_$VXWORKS_VER.tar.gz"
AltUrl=""
sha1="35a457999b310a6128e3bd7de3103c2235063071"
targetFolder="/opt/"
InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$sha1" "$targetFolder" ""
SetEnvVar "VXWORKS_HOME" "/opt/vxworks"

VXWORKS_BUILD_VER="20240326"
######### VXworks toolchain #########
# Installs to /opt/fsl_imx6_2_0_6_2_VSB
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/vxworks/vxworks_vsb_${VXWORKS_BUILD_VER}_2.tar.gz"
AltUrl=""
sha1="415359ac124e11198a3911c9c4b923269d8da83a"
targetFolder="/opt/"
InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$sha1" "$targetFolder" ""
SetEnvVar "WIND_CC_SYSROOT" "/opt/fsl_imx6_2_0_6_2_VSB"

######### VXworks VIP kernel #########
# Installs to /opt/fsl_imx6_2_0_6_2_VIP_QEMU
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/vxworks/vxworks_vip_${VXWORKS_BUILD_VER}.tar.gz"
AltUrl=""
sha1="a6019012a8c7af760469959e2df89875f5ff4e9a"
targetFolder="/opt/"
InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$sha1" "$targetFolder" ""

SetEnvVar "VXWORKS_SSH" "WindRiver@10.0.2.4"

# Setup NFS exports that are needed by VxWorks qemu
sudo bash -c "echo '/home/qt/work 10.0.2.4/24(rw,sync,root_squash,no_subtree_check,anonuid=1000,anongid=1000)' >> /etc/exports"
sudo bash -c "echo '/opt/fsl_imx6_2_0_6_2_VSB 10.0.2.4/24(rw,sync,root_squash,no_subtree_check,anonuid=1000,anongid=1000)' >> /etc/exports"
sudo exportfs -a

# Copy start script in place
cp "${BASH_SOURCE%/*}/../linux/vxworks_qemu_launcher.sh" "${HOME}"
SetEnvVar "VXWORKS_EMULATOR" "${HOME}/vxworks_qemu_launcher.sh"
