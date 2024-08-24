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


# https://download.oracle.com/otn_software/linux/instantclient/2350000/instantclient-basiclite-linux.x64-23.5.0.24.07.zip
# https://download.oracle.com/otn_software/linux/instantclient/2350000/instantclient-sdk-linux.x64-23.5.0.24.07.zip

version=23.5.0.24.07
distdir=instantclient_23_5
installFolder=/opt/oracle
upstreamRepo=https://download.oracle.com/otn_software/linux/instantclient/2350000
localRepo=http://ci-files01-hki.ci.qt.io/input/oracle

if [ -d "${installFolder}" ]; then
  sudo rm -rf ${installFolder};
fi
sudo mkdir ${installFolder}

# basic files (libs) - maybe not even needed for compilation only
echo "Fetching files..."

packageFile=instantclient-basiclite-linux.x64-${version}.zip
sha=c663ca78e64d5ba9d25cc73ede79defecb4776c0
DownloadURL  $localRepo/$packageFile $upstreamRepo/$packageFile $sha /tmp/$packageFile
echo "Unpacking ${packageFile}"
sudo unzip -o -q /tmp/${packageFile} -d ${installFolder}
echo "Remove downloaded ${packageFile} ..."
rm -rf /tmp/${packageFile}

packageFile=instantclient-sdk-linux.x64-${version}.zip
sha=7cb72cda0b89c3488afd4b7b30af5fc8444483a3
DownloadURL  $localRepo/$packageFile $upstreamRepo/$packageFile $sha /tmp/$packageFile
echo "Unpacking ${packageFile}"
sudo unzip -o -q /tmp/${packageFile} -d ${installFolder}
echo "Remove downloaded ${packageFile} ..."
rm -rf /tmp/${packageFile}

SetEnvVar "Oracle_ROOT" "${installFolder}/${distdir}/sdk/"

echo "Oracle Instant Client = $version" >> ~/versions.txt
