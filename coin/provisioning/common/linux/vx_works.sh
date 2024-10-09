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
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/vxworks/vxworks_libs_2403.tar.gz"
AltUrl=""
sha1="8152c527ca489b1e51f2954e6e88c6daa22d88f6"
targetFolder="/opt"
InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$sha1" "$targetFolder" ""
SetEnvVar "VXWORKS_HOME" "/opt/vxworks"
SetEnvVar "VXWORKS_SSH" "WindRiver@172.31.1.10"

VXWORKS_BUILD_VER="26-08-2024"
######### VXworks toolchain #########
# Installs to /opt/fsl_imx6_2_0_6_2_VSB
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/vxworks/vxworks_arm_vsb_${VXWORKS_BUILD_VER}.tar.gz"
AltUrl=""
sha1="e3c7db136e25d2ef31f5f8d2fecb10191793fdf0"
targetFolder="/opt/"
InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$sha1" "$targetFolder" ""
SetEnvVar "WIND_CC_SYSROOT" "/opt/fsl_imx6_2_0_6_2_VSB"

######### VXworks VIP kernel #########
# Installs to /opt/fsl_imx6_2_0_6_2_VIP_QEMU
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/vxworks/vxworks_arm_vip_${VXWORKS_BUILD_VER}.tar.gz"
AltUrl=""
sha1="787555c2fb2571afac7c6706b8bc2ddc65effdf8"
targetFolder="/opt/"
InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$sha1" "$targetFolder" ""

VXWORKS_BUILD_VER="11-10-2024"
# Installs to /opt/itl_generic_skylake_VSB
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/vxworks/vxworks_intel_vsb_${VXWORKS_BUILD_VER}.tar.gz"
AltUrl=""
sha1="52a3d774d247aa4abb1942fa6c3ac7eaa625babe"
targetFolder="/opt/"
InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$sha1" "$targetFolder" ""
# Installs to /opt/itl_generic_skylake_VIP_QEMU
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/vxworks/vxworks_intel_vip_${VXWORKS_BUILD_VER}.tar.gz"
AltUrl=""
sha1="3dc7c2be5f5194c3cc4b9d7d0c1bc8c6c1a37c93"
targetFolder="/opt/"
InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$sha1" "$targetFolder" ""

######### VXworks fonts and certs #########
# Installs to /opt/fsl_imx6_2_0_6_2_VSB
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/vxworks/vxworks_misc.tar.gz"
AltUrl=""
sha1="1bc529b90b35b0b249f219e47d5798225a9b68d8"
targetFolder="/opt/fsl_imx6_2_0_6_2_VSB/"
InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$sha1" "$targetFolder" ""
######### VXworks fonts and certs #########
# Installs to /opt/itl_generic_skylake_VSB
PrimaryUrl="http://ci-files01-hki.ci.qt.io/input/vxworks/vxworks_misc.tar.gz"
AltUrl=""
sha1="1bc529b90b35b0b249f219e47d5798225a9b68d8"
targetFolder="/opt/itl_generic_skylake_VSB/"
InstallFromCompressedFileFromURL "$PrimaryUrl" "$AltUrl" "$sha1" "$targetFolder" ""

# Setup NFS exports that are needed by VxWorks qemu
sudo bash -c "echo '/home/qt/work 172.31.1.10/24(rw,sync,root_squash,no_subtree_check,anonuid=2001,anongid=100)' >> /etc/exports"
sudo bash -c "echo '/opt/fsl_imx6_2_0_6_2_VSB 172.31.1.10/24(rw,sync,root_squash,no_subtree_check,anonuid=2001,anongid=100)' >> /etc/exports"
sudo bash -c "echo '/opt/itl_generic_skylake_VSB 172.31.1.10/24(rw,sync,root_squash,no_subtree_check,anonuid=2001,anongid=100)' >> /etc/exports"

sudo exportfs -a

# Enable ipv4 routing from vxWorks to Qt DNS
sudo sed -i s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g /etc/sysctl.conf
sudo iptables -I FORWARD 1 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o ens3 -j MASQUERADE

# Copy start script in place
cp "${BASH_SOURCE%/*}/../linux/vxworks_qemu_launcher.sh" "${HOME}"
SetEnvVar "VXWORKS_EMULATOR" "${HOME}/vxworks_qemu_launcher.sh"
