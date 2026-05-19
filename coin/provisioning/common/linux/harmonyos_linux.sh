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

sudo mkdir -p "$sdkTargetFolder"

basePath="http://ci-files01-hki.ci.qt.io/input/harmonyos"

toolsVersion="6.1.0.850"
toolsFile="commandline-tools-linux-x64-6.1.0.850.zip"
toolsSha1="6fdf7dbe0faddeb6a36cc76752faaf03d2abd462"

toolsTargetFile="/tmp/$toolsFile"
toolsSourceFile="$basePath/$toolsFile"

echo "Download and unzip HarmonyOS SDK"
DownloadURL "$toolsSourceFile" "$toolsSourceFile" "$toolsSha1" "$toolsTargetFile"
echo "Unzipping HarmonyOS Tools to '$targetFolder'"
sudo unzip -q "$toolsTargetFile" -d "$targetFolder"
rm "$toolsTargetFile"

patchFile="harmonyos_sdk_patches.zip"
patchSha1="7f912104a5600bc176891bc6e9d97732f4266ad6"

patchTargetFile="/tmp/$patchFile"
patchSourceFile="$basePath/$patchFile"
patchTargetFolder="$targetFolder/harmonyos_sdk_patches"

echo "Download and unzip HarmonyOS SDK patches"
DownloadURL "$patchSourceFile" "$patchSourceFile" "$patchSha1" "$patchTargetFile"
echo "Unzipping HarmonyOS SDK patches to '$targetFolder'"
sudo unzip -q "$patchTargetFile" -d "$targetFolder"
rm "$patchTargetFile"

echo "Changing ownership of HarmonyOS files."
if uname -a |grep -q "el7"; then
    sudo chown -R qt:wheel "$sdkTargetFolder"
    sudo chown -R qt:wheel "$patchTargetFolder"
else
    sudo chown -R qt:users "$sdkTargetFolder"
    sudo chown -R qt:users "$patchTargetFolder"
fi

echo "Patching HarmonyOS SDK"

sdkRootFolder="$sdkTargetFolder/sdk/default/openharmony"
echo "Checking the contents of HarmonyOS SDK..."
ls -l "$sdkRootFolder"

SetEnvVar "HARMONYOS_SDK_ROOT" "$sdkRootFolder"
export HARMONYOS_SDK_ROOT="$sdkRootFolder"

echo "HarmonyOS SDK setup finished"
