#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script install Android sdk and ndk.

# It also runs update for SDK API, latest SDK tools, latest platform-tools and build-tools version

set -ex

# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

targetFolder="/opt/android"
sdkTargetFolder="$targetFolder/sdk"

basePath="/net/ci-files01-hki.ci.qt.io/hdd/www/input/android"

toolsVersion="2.1"
# toolsFile dertermines tools version
toolsFile="commandlinetools-mac-6609375_latest.zip"

ndkVersionLatest="r26b"
ndkVersionDefault="$ndkVersionLatest"
sdkBuildToolsVersion="34.0.0"
# this is compile sdk version
sdkApiLevel="android-34"

toolsSourceFile="$basePath/$toolsFile"

function InstallNdk() {

    ndkVersion=$1

    if [[ ! -d "${targetFolder}/android-ndk-${ndkVersion}" ]]; then
        echo "Unzipping Android NDK $ndkVersion to '${targetFolder}'"
        ndkSourceFile="$basePath/android-ndk-$ndkVersion-darwin*.zip"
        sudo unzip -q "$ndkSourceFile" -d "$targetFolder"
    fi

}

InstallNdk $ndkVersionDefault
InstallNdk $ndkVersionLatest

echo "Unzipping Android Tools to '$sdkTargetFolder'"
sudo unzip -q "$toolsSourceFile" -d "$sdkTargetFolder"

echo "Changing ownership of Android files."
sudo chown -R qt:wheel "$targetFolder"
sudo chmod -R 755 $targetFolder

# Run the following command under `eval` or `sh -c` so that the shell properly splits it
sdkmanager_no_progress_bar_cmd="tr '\r' '\n'  |  grep -v '^\[[ =]*\]'"

sudo mkdir "$sdkTargetFolder/cmdline-tools"
sudo mv "$sdkTargetFolder/tools" "$sdkTargetFolder/cmdline-tools"

echo "Running SDK manager for platforms;$sdkApiLevel, platform-tools and build-tools;$sdkBuildToolsVersion."
(echo "y"; echo "y") | "$sdkTargetFolder/cmdline-tools/tools/bin/sdkmanager" "--sdk_root=$sdkTargetFolder" \
    "platforms;$sdkApiLevel" "platform-tools" "build-tools;$sdkBuildToolsVersion"  \
    | eval "$sdkmanager_no_progress_bar_cmd"

echo "Checking the contents of Android SDK..."
ls -l "$sdkTargetFolder"

SetEnvVar "ANDROID_SDK_ROOT" "$sdkTargetFolder"
SetEnvVar "ANDROID_NDK_ROOT_DEFAULT" "$targetFolder/android-ndk-$ndkVersionDefault"
SetEnvVar "ANDROID_NDK_ROOT_LATEST" "$targetFolder/android-ndk-$ndkVersionLatest"
SetEnvVar "ANDROID_NDK_HOST" "darwin-x86_64"
SetEnvVar "ANDROID_API_VERSION" "$sdkApiLevel"

cat << EOT >>~/versions.txt
Android SDK tools = $toolsVersion
Android SDK Build Tools = $sdkBuildToolsVersion
Android SDK API level = $sdkApiLevel
Android NDK = $ndkVersionDefault
EOT
