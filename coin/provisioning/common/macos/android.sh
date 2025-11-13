#!/usr/bin/env bash
# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script install Android sdk and ndk.

# It also runs update for SDK API, latest SDK tools, latest platform-tools and build-tools version

set -ex

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/check_and_set_proxy.sh
source "${BASH_SOURCE%/*}/../unix/check_and_set_proxy.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

targetFolder="/opt/android"
sdkTargetFolder="$targetFolder/sdk"

sudo mkdir -p "$sdkTargetFolder"

basePath="http://ci-files01-hki.ci.qt.io/input/android"

toolsVersion="19.0"
toolsFile="commandlinetools-mac-13114758_latest.zip"
toolsBackupUrl="https://dl.google.com/android/repository/$toolsFile"
sdkBuildToolsVersion="35.0.1"
sdkApiLevel="android-35"
toolsSha1="c3e06a1959762e89167d1cbaa988605f6f7c1d24"

ndkVersionLatest="r27c"
ndkSha1Latest="0217c10ffbec496bb9fbfbb3c6fc2477c6b77297"

# Preview NDK that is in alpha/beta/RC state
ndkVersionPreview="r29-beta2"
ndkSha1Preview="09be4f8fb626a9c93415198ea8e75d8d82f528fa"

# Non-latest (but still supported by the qt/qt5 branch) NDKs are installed for nightly targets in:
# coin/platform_configs/nightly_android.yaml

ndkVersionNightly1=$ndkVersionLatest  # Set as same version as latest = skip NDK install in provisioning
ndkSha1Nightly1=$ndkSha1Latest

ndkVersionNightly2=$ndkVersionLatest
ndkSha1Nightly2=$ndkSha1Latest

toolsTargetFile="/tmp/$toolsFile"
toolsSourceFile="$basePath/$toolsFile"

echo "Download and unzip Android SDK"
DownloadURL "$toolsSourceFile" "$toolsBackupUrl" "$toolsSha1" "$toolsTargetFile"
echo "Unzipping Android Tools to '$sdkTargetFolder'"
sudo unzip -q "$toolsTargetFile" -d "$sdkTargetFolder"
rm "$toolsTargetFile"

# Android Command-Line Tools unpacks a directory 'cmdline-tools'. Due
# to existing code, we need to move it into 'cmdline-tools/tools'
sudo mv "$sdkTargetFolder/cmdline-tools" "$sdkTargetFolder/tools"
sudo mkdir "$sdkTargetFolder/cmdline-tools"
sudo mv "$sdkTargetFolder/tools" "$sdkTargetFolder/cmdline-tools"

function InstallNdk() {

    ndkVersion=$1
    ndkSha1=$2

    ndkFile="android-ndk-$ndkVersion-darwin.zip"
    ndkTargetFile="/tmp/$ndkFile"
    ndkSourceFile="$basePath/$ndkFile"

    DownloadURL "$ndkSourceFile" "$ndkSourceFile" "$ndkSha1" "$ndkTargetFile"
    echo "Unzipping Android NDK to '$targetFolder'"
    # Get the package base directory name as string
    zipBase=$(sudo zipinfo -1 "$ndkTargetFile" 2>/dev/null | awk '!seen {sub("/.*",""); print; seen=1}')
    sudo unzip -q "$ndkTargetFile" -d "$targetFolder"
    rm "$ndkTargetFile"
    androidNdkRoot="${targetFolder}/${zipBase}"
}

InstallNdk $ndkVersionLatest $ndkSha1Latest
SetEnvVar "ANDROID_NDK_ROOT_LATEST" "$androidNdkRoot"

if [ "$ndkVersionPreview" != "$ndkVersionLatest" ]; then
    InstallNdk $ndkVersionPreview $ndkSha1Preview
    SetEnvVar "ANDROID_NDK_ROOT_PREVIEW" "$androidNdkRoot"
fi

if [ "$ndkVersionNightly1" != "$ndkVersionLatest" ]; then
    InstallNdk $ndkVersionNightly1 $ndkSha1Nightly1
    SetEnvVar "ANDROID_NDK_ROOT_NIGHTLY1" "$androidNdkRoot"
fi

if [ "$ndkVersionNightly2" != "$ndkVersionLatest" ]; then
    InstallNdk $ndkVersionNightly2 $ndkSha1Nightly2
    SetEnvVar "ANDROID_NDK_ROOT_NIGHTLY2" "$androidNdkRoot"
fi

echo "Changing ownership of Android files."
sudo chown -R qt:wheel "$targetFolder"
sudo chmod -R 755 $targetFolder

# Stop the sdkmanager from printing thousands of lines of #hashmarks.
# Run the following command under `eval` or `sh -c` so that the shell properly splits it.
sdkmanager_no_progress_bar_cmd="tr '\r' '\n'  |  grep -v '^\[[ =]*\]'"
# But don't let the pipeline hide sdkmanager failures.
set -o pipefail

echo "Running SDK manager for platforms;$sdkApiLevel, platform-tools and build-tools;$sdkBuildToolsVersion."
# shellcheck disable=SC2031
if [ "$http_proxy" != "" ]; then
    proxy_host=$(echo "$proxy" | cut -d'/' -f3 | cut -d':' -f1)
    proxy_port=$(echo "$proxy" | cut -d':' -f3)
    echo "y" | "$sdkTargetFolder/cmdline-tools/tools/bin/sdkmanager" --sdk_root=$sdkTargetFolder  \
                   --no_https --proxy=http --proxy_host="$proxy_host" --proxy_port="$proxy_port"  \
                   "platforms;$sdkApiLevel" "platform-tools" "build-tools;$sdkBuildToolsVersion"  \
        | eval "$sdkmanager_no_progress_bar_cmd"
else
    echo "y" | "$sdkTargetFolder/cmdline-tools/tools/bin/sdkmanager" --sdk_root=$sdkTargetFolder  \
                   "platforms;$sdkApiLevel" "platform-tools" "build-tools;$sdkBuildToolsVersion"  \
        | eval "$sdkmanager_no_progress_bar_cmd"
fi

echo "Checking the contents of Android SDK..."
ls -l "$sdkTargetFolder"

SetEnvVar "ANDROID_SDK_ROOT" "$sdkTargetFolder"
SetEnvVar "ANDROID_NDK_HOST" "darwin-x86_64"
SetEnvVar "ANDROID_API_VERSION" "$sdkApiLevel"

cat << EOT >>~/versions.txt
Android SDK tools = $toolsVersion
Android SDK Build Tools = $sdkBuildToolsVersion
Android SDK API level = $sdkApiLevel
Android NDK latest = $ndkVersionLatest
Android NDK nightly1 = $ndkVersionNightly1
Android NDK nightly2 = $ndkVersionNightly2
EOT
