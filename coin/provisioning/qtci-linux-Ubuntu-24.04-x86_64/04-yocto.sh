#!/usr/bin/env bash
# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs the Yocto toolchain

set -ex

# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"
# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"

primaryBaseUrlPath="http://ci-files01-hki.ci.qt.io/input/boot2qt/gatesgarth"
altBaseUrlPath="http://download.qt.io/development_releases/prebuilt/boot2qt/gatesgarth"

echo "Installing Yocto toolchain for 32-bit b2qt ARMV7..."

versionARM="3.2"
package="b2qt-x86_64-meta-toolchain-b2qt-ci-sdk-qemuarm-a9d5156a.sh"
PrimaryUrl="$primaryBaseUrlPath/$package"
AltUrl="$altBaseUrlPath/$package"
SHA1="f9f7d51656067a1cc9d7ab92ddcddb219886ab22"
yoctoInstaller="/tmp/yocto-toolchain-ARMv7.sh"
yoctoLocationARMv7="/opt/b2qt/$versionARM"
sysrootARMv7="armv7vet2hf-neon-poky-linux-gnueabi"
crosscompileARMv7="sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-"
envSetupARMv7="environment-setup-$sysrootARMv7"
toolchainFileARMv7="sysroots/x86_64-pokysdk-linux/usr/share/cmake/OEToolchainConfig.cmake"

DownloadURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$yoctoInstaller"
chmod +x "$yoctoInstaller"

/bin/bash "$yoctoInstaller" -y -d "$yoctoLocationARMv7"
rm -rf "$yoctoInstaller"

echo "Installing Yocto toolchain for 64-bit b2qt ARM64..."

versionARM64="3.2"
package="b2qt-x86_64-meta-toolchain-b2qt-ci-sdk-qemuarm64-a9d5156a.sh"
PrimaryUrl="$primaryBaseUrlPath/$package"
AltUrl="$altBaseUrlPath/$package"
SHA1="f490cbcc4e0d5a87f4e07607a71013aeeabce94a"
yoctoInstaller="/tmp/yocto-toolchain-ARM64.sh"
yoctoLocationARM64="/opt/b2qt/$versionARM64"
sysrootARM64="cortexa57-poky-linux"
crosscompileARM64="sysroots/x86_64-pokysdk-linux/usr/bin/aarch64-poky-linux/aarch64-poky-linux-"
envSetupARM64="environment-setup-$sysrootARM64"
toolchainFileARM64="sysroots/x86_64-pokysdk-linux/usr/share/cmake/OEToolchainConfig.cmake"

DownloadURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$yoctoInstaller"
chmod +x "$yoctoInstaller"

/bin/bash "$yoctoInstaller" -y -d "$yoctoLocationARM64"
rm -rf "$yoctoInstaller"

echo "Installing Yocto toolchain for 64-bit b2qt MIPS64..."

versionMIPS64="3.2"
package="b2qt-x86_64-meta-toolchain-b2qt-ci-sdk-qemumips64-a9d5156a.sh"
PrimaryUrl="$primaryBaseUrlPath/$package"
AltUrl="$altBaseUrlPath/$package"
SHA1="5d3a8bb4384de273937286d275d1dab36f969951"
yoctoInstaller="/tmp/yocto-toolchain-mips64.sh"
yoctoLocationMIPS64="/opt/b2qt/$versionMIPS64"
sysrootMIPS64="mips64r2-poky-linux"
crosscompileMIPS64="sysroots/x86_64-pokysdk-linux/usr/bin/mips64-poky-linux/mips64-poky-linux-"
envSetupMIPS64="environment-setup-$sysrootMIPS64"
toolchainFileMIPS64="sysroots/x86_64-pokysdk-linux/usr/share/cmake/OEToolchainConfig.cmake"

DownloadURL "$PrimaryUrl" "$AltUrl" "$SHA1" "$yoctoInstaller"
chmod +x "$yoctoInstaller"

/bin/bash "$yoctoInstaller" -y -d "$yoctoLocationMIPS64"
rm -rf "$yoctoInstaller"



if [ -e "$yoctoLocationARMv7/sysroots/$sysrootARMv7" ] && [ -e "$yoctoLocationARMv7/${crosscompileARMv7}g++" ] && \
   [ -e "$yoctoLocationARMv7/$envSetupARMv7" ] && [ -e "$yoctoLocationARMv7/$toolchainFileARMv7" ] && \
   [ -e "$yoctoLocationARM64/sysroots/$sysrootARM64" ] && [ -e "$yoctoLocationARM64/${crosscompileARM64}g++" ] && \
   [ -e "$yoctoLocationARM64/$envSetupARM64" ] && [ -e "$yoctoLocationARM64/$toolchainFileARM64" ] && \
   [ -e "$yoctoLocationMIPS64/sysroots/$sysrootMIPS64" ] && [ -e "$yoctoLocationMIPS64/${crosscompileMIPS64}g++" ] && \
   [ -e "$yoctoLocationMIPS64/$envSetupMIPS64" ] && [ -e "$yoctoLocationMIPS64/$toolchainFileMIPS64" ]; then
    SetEnvVar "QEMUARMV7_TOOLCHAIN_SYSROOT" "$yoctoLocationARMv7/sysroots/$sysrootARMv7"
    SetEnvVar "QEMUARMV7_TOOLCHAIN_CROSS_COMPILE" "$yoctoLocationARMv7/$crosscompileARMv7"
    SetEnvVar "QEMUARMV7_TOOLCHAIN_ENVSETUP" "$yoctoLocationARMv7/$envSetupARMv7"
    SetEnvVar "QEMUARMV7_TOOLCHAIN_FILE" "$yoctoLocationARMv7/$toolchainFileARMv7"
    SetEnvVar "QEMUARM64_TOOLCHAIN_SYSROOT" "$yoctoLocationARM64/sysroots/$sysrootARM64"
    SetEnvVar "QEMUARM64_TOOLCHAIN_CROSS_COMPILE" "$yoctoLocationARM64/$crosscompileARM64"
    SetEnvVar "QEMUARM64_TOOLCHAIN_ENVSETUP" "$yoctoLocationARM64/$envSetupARM64"
    SetEnvVar "QEMUARM64_TOOLCHAIN_FILE" "$yoctoLocationARM64/$toolchainFileARM64"
    SetEnvVar "QEMUMIPS64_TOOLCHAIN_SYSROOT" "$yoctoLocationMIPS64/sysroots/$sysrootMIPS64"
    SetEnvVar "QEMUMIPS64_TOOLCHAIN_CROSS_COMPILE" "$yoctoLocationMIPS64/$crosscompileMIPS64"
    SetEnvVar "QEMUMIPS64_TOOLCHAIN_ENVSETUP" "$yoctoLocationMIPS64/$envSetupMIPS64"
    SetEnvVar "QEMUMIPS64_TOOLCHAIN_FILE" "$yoctoLocationMIPS64/$toolchainFileMIPS64"
else
    echo "Error! Couldn't find installation paths for Yocto toolchain. Aborting provisioning." 1>&2
    exit 1
fi

cat << EOB >> ~/versions.txt
Yocto ARMv7 toolchain = $versionARM
Yocto ARM64 toolchain = $versionARM64
Yocto MIPS64 toolchain = $versionMIPS64
EOB

# List qt user in qemu toolchain sysroots
sudo sh -c "grep ^qt /etc/passwd >> $yoctoLocationARMv7/sysroots/$sysrootARMv7/etc/passwd"
sudo sh -c "grep ^qt /etc/group >> $yoctoLocationARMv7/sysroots/$sysrootARMv7/etc/group"
sudo sh -c "grep ^qt /etc/passwd >> $yoctoLocationARM64/sysroots/$sysrootARM64/etc/passwd"
sudo sh -c "grep ^qt /etc/group >> $yoctoLocationARM64/sysroots/$sysrootARM64/etc/group"

# Fix mdns to support both docker and network tests
# See also https://bugreports.qt.io/browse/QTBUG-106013
sudo sh -c "sed -i '/^hosts:/s/.*/hosts:          files myhostname mdns_minimal [NOTFOUND=return] dns mdns4/'   $yoctoLocationARMv7/sysroots/$sysrootARMv7/etc/nsswitch.conf"
sudo sh -c "sed -i '/^hosts:/s/.*/hosts:          files myhostname mdns_minimal [NOTFOUND=return] dns mdns4/'   $yoctoLocationARM64/sysroots/$sysrootARM64/etc/nsswitch.conf"

# Install qemu binfmt for 32bit and 64bit arm architectures
sudo update-binfmts --package qemu-arm --install arm $yoctoLocationARMv7/sysroots/x86_64-pokysdk-linux/usr/bin/qemu-arm \
--magic "\x7f\x45\x4c\x46\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00" \
--mask "\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff"
sudo update-binfmts --package qemu-aarch64 --install aarch64 $yoctoLocationARM64/sysroots/x86_64-pokysdk-linux/usr/bin/qemu-aarch64 \
--magic "\x7f\x45\x4c\x46\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00" \
--mask "\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff"
