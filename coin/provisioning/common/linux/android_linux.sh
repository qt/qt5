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

# This script install Android sdk and ndk.

# It also runs update for SDK API, latest SDK tools, latest platform-tools and build-tools version

# shellcheck source=../unix/DownloadURL.sh
source "${BASH_SOURCE%/*}/../unix/DownloadURL.sh"
# shellcheck source=../unix/check_and_set_proxy.sh
source "${BASH_SOURCE%/*}/../unix/check_and_set_proxy.sh"
# shellcheck source=../unix/SetEnvVar.sh
source "${BASH_SOURCE%/*}/../unix/SetEnvVar.sh"

targetFolder="/opt/android"
sdkTargetFolder="$targetFolder/sdk"

basePath="http://ci-files01-hki.intra.qt.io/input/android"

toolsVersion="r25.2.5"
toolsFile="tools_$toolsVersion-linux.zip"
ndkVersion="r10e"
ndkFile="android-ndk-$ndkVersion-linux-x86_64.zip"
sdkBuildToolsVersion="25.0.2"
sdkApiLevel="android-21"

toolsSha1="72df3aa1988c0a9003ccdfd7a13a7b8bd0f47fc1"
ndkSha1="f692681b007071103277f6edc6f91cb5c5494a32"

toolsTargetFile="/tmp/$toolsFile"
toolsSourceFile="$basePath/$toolsFile"
ndkTargetFile="/tmp/$ndkFile"
ndkSourceFile="$basePath/$ndkFile"

DownloadURL "$toolsSourceFile" "$toolsSourceFile" "$toolsSha1" "$toolsTargetFile"
DownloadURL "$ndkSourceFile" "$ndkSourceFile" "$ndkSha1" "$ndkTargetFile"
echo "Unzipping Android NDK to '$targetFolder'"
sudo unzip -q "$ndkTargetFile" -d "$targetFolder"
echo "Unzipping Android Tools to '$sdkTargetFolder'"
sudo unzip -q "$toolsTargetFile" -d "$sdkTargetFolder"
rm "$ndkTargetFile"
rm "$toolsTargetFile"

echo "Changing ownership of Android files."
if uname -a |grep -q "el6\|el7"; then
    sudo chown -R qt:wheel "$targetFolder"
else
    sudo chown -R qt:users "$targetFolder"
fi

echo "Running SDK manager for platforms;$sdkApiLevel, tools, platform-tools and build-tools;$sdkBuildToolsVersion."
# shellcheck disable=SC2031
if [ "$http_proxy" != "" ]; then
    proxy_host=$(echo "$proxy" | cut -d'/' -f3 | cut -d':' -f1)
    proxy_port=$(echo "$proxy" | cut -d':' -f3)
    echo "y" |"$sdkTargetFolder/tools/bin/sdkmanager" --no_https --proxy=http --proxy_host="$proxy_host" --proxy_port="$proxy_port" "platforms;$sdkApiLevel" "tools" "platform-tools" "build-tools;$sdkBuildToolsVersion"
else
    echo "y" |"$sdkTargetFolder/tools/bin/sdkmanager" "platforms;$sdkApiLevel" "tools" "platform-tools" "build-tools;$sdkBuildToolsVersion"
fi

SetEnvVar "ANDROID_SDK_HOME" "$sdkTargetFolder"
SetEnvVar "ANDROID_NDK_HOME" "$targetFolder/android-ndk-$ndkVersion"
SetEnvVar "ANDROID_NDK_HOST" "linux-x86_64"
SetEnvVar "ANDROID_API_VERSION" "$sdkApiLevel"

# shellcheck disable=SC2129
echo "Android SDK tools = $toolsVersion" >> ~/versions.txt
echo "Android SDK Build Tools = $sdkBuildToolsVersion" >> ~/versions.txt
echo "Android SDK API level = $sdkApiLevel" >> ~/versions.txt
echo "Android NDK = $ndkVersion" >> ~/versions.txt

cd "$sdkTargetFolder/tools/bin"
echo "y" | ./sdkmanager --install "system-images;android-21;google_apis;x86"
echo "no" | ./avdmanager create avd -n x86emulator -k "system-images;android-21;google_apis;x86" -c 2048M -f
# Purely informative, show the list of avd devices
./avdmanager list avd
