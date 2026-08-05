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

toolsVersion="6.1.0.860"
toolsFile="commandline-tools-mac-arm64-6.1.0.860.zip"
toolsSha1="4ba9df069fc5c651753c74297d723a2461be12e9"

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
sudo chown -R qt:wheel "$sdkTargetFolder"
sudo chmod -R 755 $sdkTargetFolder
sudo chown -R qt:wheel "$patchTargetFolder"
sudo chmod -R 755 $patchTargetFolder

echo "Patching HarmonyOS SDK"

sdkRootFolder="$sdkTargetFolder/sdk/default/openharmony"
echo "Checking the contents of HarmonyOS SDK..."
ls -l "$sdkRootFolder"

SetEnvVar "HARMONYOS_SDK_ROOT" "$sdkRootFolder"
export HARMONYOS_SDK_ROOT="$sdkRootFolder"

echo "HarmonyOS SDK setup finished"
