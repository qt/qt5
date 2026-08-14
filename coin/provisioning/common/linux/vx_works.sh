#!/usr/bin/env bash
# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs vxworks libs and toolchain.

set -ex

# shellcheck source=../unix/InstallFromCompressedFileFromURL.sh
source "${BASH_SOURCE%/*}/../unix/InstallFromCompressedFileFromURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

######### VXworks libs #########
# Installs to /opt/vxworks
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/vxworks/vxworks_libs_2603.tar.gz"
AltUrl=""
sha1="e9337894d4591e1d9e67640181c3d48fdb3d4a12"
targetFolder="/opt"
InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$sha1" "$targetFolder" ""
SetEnvVar "VXWORKS_HOME" "/opt/vxworks"
SetEnvVar "VXWORKS_SSH" "WindRiver@172.31.1.10"

# IMX 6
VXWORKS_BUILD_VER="20-08-2026"
######### VXworks toolchain #########
# Installs to /opt/fsl_imx6_2_0_6_3_VSB
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/vxworks/vxworks_arm_vsb_${VXWORKS_BUILD_VER}.tar.gz"
AltUrl=""
sha1="cb40acde7227aaefe8397e3472318fe09af2d9d0"
targetFolder="/opt/"
InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$sha1" "$targetFolder" ""
SetEnvVar "WIND_CC_SYSROOT" "/opt/fsl_imx6_2_0_6_3_VSB"

######### VXworks VIP kernel #########
# Installs to /opt/fsl_imx6_2_0_6_3_VIP_QEMU
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/vxworks/vxworks_arm_vip_${VXWORKS_BUILD_VER}.tar.gz"
AltUrl=""
sha1="4209a8c2724fccfec9d30a22e53ca6598ef83b57"
targetFolder="/opt/"
InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$sha1" "$targetFolder" ""

# IMX 8
# Installs to /opt/nxp_imx8_1_0_7_1_VSB
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/vxworks/vxworks_arm_imx8_vsb_${VXWORKS_BUILD_VER}.tar.gz"
AltUrl=""
sha1="20c1c31fc8ddc5356566a717a913e51bef42d41f"
targetFolder="/opt/"
InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$sha1" "$targetFolder" ""

# Installs to /opt/itl_generic_skylake_VSB
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/vxworks/vxworks_intel_vsb_${VXWORKS_BUILD_VER}.tar.gz"
AltUrl=""
sha1="dae9280a45f0ece5a2adc3bc6182ff0b675f4389"
targetFolder="/opt/"
InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$sha1" "$targetFolder" ""
# Installs to /opt/itl_generic_skylake_VIP_QEMU
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/vxworks/vxworks_intel_vip_${VXWORKS_BUILD_VER}.tar.gz"
AltUrl=""
sha1="264b3280e6fa89c8c8a2b1cdc8cb29bd3f1bb621"
targetFolder="/opt/"
InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$sha1" "$targetFolder" ""

######### VXworks fonts and certs #########
# Installs to /opt/fsl_imx6_2_0_6_3_VSB
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/vxworks/vxworks_misc.tar.gz"
AltUrl=""
sha1="1bc529b90b35b0b249f219e47d5798225a9b68d8"
targetFolder="/opt/fsl_imx6_2_0_6_3_VSB/"
InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$sha1" "$targetFolder" ""
######### VXworks fonts and certs #########
# Installs to /opt/itl_generic_skylake_VSB
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/vxworks/vxworks_misc.tar.gz"
AltUrl=""
sha1="1bc529b90b35b0b249f219e47d5798225a9b68d8"
targetFolder="/opt/itl_generic_skylake_VSB/"
InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$sha1" "$targetFolder" ""

# Enable ipv4 routing from vxWorks to Qt DNS
sudo sed -i s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g /etc/sysctl.conf
sudo iptables -I FORWARD 1 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o ens3 -j MASQUERADE

# Copy start script in place
cp "${BASH_SOURCE%/*}/../linux/vxworks_qemu_launcher.sh" "${HOME}"
SetEnvVar "VXWORKS_EMULATOR" "${HOME}/vxworks_qemu_launcher.sh"
