#!/usr/bin/env bash
# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script install HarmonyOS sdk and patches.

set -e

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/check_and_set_proxy.sh
source "${BASH_SOURCE%/*}/../unix/check_and_set_proxy.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

targetFolder="/opt/harmonyos"
sdkTargetFolder="$targetFolder/command-line-tools"

basePath="http://ci-files01-hki.ci.qt.io/input/harmonyos"

function InstallCommandLineTools() {

    cltVersion=$1
    cltSha1=$2

    cltFile="commandline-tools-linux-x64-$cltVersion.zip"
    cltTargetFile="/tmp/$cltFile"
    cltSourceFile="$basePath/$cltFile"

    cltTargetDir="$targetFolder/$cltVersion"
    sudo mkdir -p "$cltTargetDir"

    DownloadURL "$cltSourceFile" "$cltSourceFile" "$cltSha1" "$cltTargetFile"
    echo "Unzipping HarmonyOS Command Line Tools to '$cltTargetDir'"
    # Get the package base directory name as string
    zipBase=$(sudo zipinfo -1 "$cltTargetFile" 2>/dev/null | awk '!seen {sub("/.*",""); print; seen=1}')
    sudo unzip -q "$cltTargetFile" -d "$cltTargetDir"
    rm "$cltTargetFile"
    harmonycltRoot="${cltTargetDir}/${zipBase}"

    echo "Changing ownership of HarmonyOS files."
    sudo chown -R qt:users "$harmonycltRoot"
}

cltVersionCurrent="6.1.0.850"
cltSha1Current="6fdf7dbe0faddeb6a36cc76752faaf03d2abd462"
InstallCommandLineTools $cltVersionCurrent $cltSha1Current
SetEnvVar "HARMONYOS_SDK_ROOT_CURRENT" "$harmonycltRoot"
sudo ln -s "$harmonycltRoot" "$sdkTargetFolder"
SetEnvVar "HARMONYOS_SDK_ROOT" "$sdkTargetFolder"

cltVersionNext="26.0.0.821"
cltSha1Next="d89fc1a09ceb5b25a350695068fe9918912785d2"
InstallCommandLineTools $cltVersionNext $cltSha1Next
SetEnvVar "HARMONYOS_SDK_ROOT_NEXT" "$harmonycltRoot"

echo "HarmonyOS SDK setup finished"
