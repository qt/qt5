#!/usr/bin/env bash
# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

set -e

PROVISIONING_DIR="$(dirname "$0")/../../"
# shellcheck source=../unix/common.sourced.sh
source "${BASH_SOURCE%/*}/../unix/common.sourced.sh"
# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

version=5.0.1
fullversion=Firebird-${version}.1469-0-linux-x64
instpath=/opt/Firebird
localRepo=http://ci-files01-hki.ci.qt.io/input/docker
upstreamRepo=https://github.com/FirebirdSQL/firebird/releases/download/v${version}
packageFile=${fullversion}.tar.gz
sha=369e9187913c6e1bc8a0f79f9e1826c0e35dd72f

DownloadURL  $localRepo/$packageFile $upstreamRepo/$packageFile $sha /tmp/$packageFile

echo "Unpacking ${packageFile}"
tar xvf /tmp/${packageFile} -C /tmp
echo "Checking unpacked directory"
echo "Starting install"
if [ -d "${instpath}" ]; then
  sudo rm -rf ${instpath};
fi
sudo mkdir ${instpath}
sudo tar xf /tmp/${fullversion}/buildroot.tar.gz -C ${instpath}

echo "Cleaning up"
rm -rf /tmp/${fullversion}
rm -rf /tmp/${packageFile}

SetEnvVar "Interbase_ROOT" "${instpath}/opt/firebird/"

echo "Firebird = $version" >> ~/versions.txt
