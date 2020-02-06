#!/usr/bin/env bash

#############################################################################
##
## Copyright (C) 2018 The Qt Company Ltd.
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

# This script install Android sdk and ndk.

# It also runs update for SDK API, latest SDK tools, latest platform-tools and build-tools version

set -e

# shellcheck source=../common/unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../common/unix/SetEnvVar.sh"

targetFolder="/opt/android"
sdkTargetFolder="$targetFolder/sdk"

basePath="/net/ci-files01-hki.intra.qt.io/hdd/www/input/android"

toolsVersion="r26.1.1"
# toolsFile dertermines tools version
toolsFile="sdk-tools-darwin-4333796.zip"

ndkVersion="r20"
ndkFile="android-ndk-$ndkVersion-darwin-x86_64.zip"
sdkBuildToolsVersion="28.0.3"
# this is compile sdk version
sdkApiLevel="android-28"

toolsSourceFile="$basePath/$toolsFile"
ndkSourceFile="$basePath/$ndkFile"

echo "Unzipping Android NDK to '$targetFolder'"
sudo unzip -q "$ndkSourceFile" -d "$targetFolder"
echo "Unzipping Android Tools to '$sdkTargetFolder'"
sudo unzip -q "$toolsSourceFile" -d "$sdkTargetFolder"

echo "Changing ownership of Android files."
sudo chown -R qt:wheel "$targetFolder"

# Stop the sdkmanager from printing thousands of lines of #hashmarks.
# Run the following command under `eval` or `sh -c` so that the shell properly splits it.
sdkmanager_no_progress_bar_cmd="tr '\r' '\n'  |  grep -v '^\[[ =]*\]'"
# But don't let the pipeline hide sdkmanager failures.
set -o pipefail

echo "Running SDK manager for platforms;$sdkApiLevel, platform-tools and build-tools;$sdkBuildToolsVersion."
(echo "y"; echo "y") | "$sdkTargetFolder/tools/bin/sdkmanager"  \
    "platforms;$sdkApiLevel" "platform-tools" "build-tools;$sdkBuildToolsVersion"  \
    | eval $sdkmanager_no_progress_bar_cmd

echo "Checking the contents of Android SDK..."
ls -l "$sdkTargetFolder"

SetEnvVar "ANDROID_SDK_HOME" "$sdkTargetFolder"
SetEnvVar "ANDROID_NDK_HOME" "$targetFolder/android-ndk-$ndkVersion"
SetEnvVar "ANDROID_NDK_ROOT" "$targetFolder/android-ndk-$ndkVersion"
SetEnvVar "ANDROID_NDK_HOST" "darwin-x86_64"
SetEnvVar "ANDROID_API_VERSION" "$sdkApiLevel"

echo "Android SDK tools = $toolsVersion" >> ~/versions.txt
echo "Android SDK Build Tools = $sdkBuildToolsVersion" >> ~/versions.txt
echo "Android SDK API level = $sdkApiLevel" >> ~/versions.txt
echo "Android NDK = $ndkVersion" >> ~/versions.txt
