#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
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

# This script install Intel Parallel Studio XE Composer Edition for C++ Linux

# shellcheck source=../common/unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../common/unix/DownloadURL.sh"

set -ex

mainStorage="ci-files01-hki.intra.qt.io:/hdd/www/input"
localMount="/mnt/storage/"

iccPackage="parallel_studio_xe_2020_update1_composer_edition_for_cpp.tgz"
iccPackageSource="$localMount/intel/$iccPackage"
iccInstallPath="/opt/intel"
iccTmpPath="/tmp/icc"

iccLicense="l_icc_2020.lic"
iccLicenseSource="$localMount/semisecure/$iccLicense"
iccLicenseTarget="/home/qt/$iccLicense"

iccInstallInstructions="$iccTmpPath/instructions.txt"

sudo mkdir -p "$localMount"
sudo mount "$mainStorage" "$localMount"
mkdir -p "$iccTmpPath"
tar -zxf "$iccPackageSource" -C "$iccTmpPath" --strip 1

cp "$iccLicenseSource" "$iccLicenseTarget"

sudo umount "$localMount"

{ serialNumber=$(cat $iccLicenseTarget | grep -e "SerialNumber" | awk -F '[=]' '{print $2}'); } 2>/dev/null

cat >"$iccInstallInstructions" <<EOT
ACCEPT_EULA=accept
CONTINUE_WITH_OPTIONAL_ERROR=yes
PSET_INSTALL_DIR=$iccInstallPath
CONTINUE_WITH_INSTALLDIR_OVERWRITE=yes
PSET_MODE=install
ACTIVATION_SERIAL_NUMBER=$serialNumber
ACTIVATION_TYPE=serial_number
INTEL_SW_IMPROVEMENT_PROGRAM_CONSENT=no
ARCH_SELECTED=INTEL64
COMPONENTS=;intel-conda-index-tool__x86_64;intel-comp__x86_64;intel-comp-doc__noarch;intel-comp-l-all-common__noarch;intel-comp-l-all-vars__noarch;intel-comp-nomcu-vars__noarch;intel-comp-ps__x86_64;intel-comp-ps-ss-bec__x86_64;intel-openmp__x86_64;intel-openmp-common__noarch;intel-openmp-common-icc__noarch;intel-tbb-libs__x86_64;intel-idesupport-icc-common-ps__noarch;intel-conda-icc_rt-linux-64-shadow-package__x86_64;intel-icc__x86_64;intel-c-comp-common__noarch;intel-icc-common__noarch;intel-icc-common-ps__noarch;intel-icc-doc__noarch;intel-icc-ps__x86_64;intel-icc-ps-ss-bec__x86_64;intel-icx__x86_64;intel-icx-common__noarch;intel-tbb-devel__x86_64;intel-tbb-common__noarch;intel-tbb-doc__noarch;intel-conda-tbb-linux-64-shadow-package__x86_64;intel-conda-tbb-devel-linux-64-shadow-package__x86_64;intel-ccompxe__noarch;intel-psxe-common__noarch;intel-psxe-doc__noarch;intel-psxe-common-doc__noarch;intel-compxe-doc__noarch;intel-psxe-licensing__noarch;intel-psxe-licensing-doc__noarch;intel-icsxe-pset
EOT

( cd "$iccTmpPath" && sudo ./install.sh --silent $iccInstallInstructions --ignore-cpu )

# Export LD_LIBRARY_PATH to Coin
echo "export ICC64_19_LDLP=$iccInstallPath/lib/intel64" >>~/.bashrc
echo "export ICC64_19_PATH=$iccInstallPath/compilers_and_libraries_2020.1.217/linux/bin/intel64:$iccInstallPath/bin" >>~/.bashrc
echo "ICC = 19.1.1.217 20200306" >> ~/versions.txt

rm -rf "$iccTmpPath"
