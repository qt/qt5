#!/bin/env bash

#############################################################################
##
## Copyright (C) 2016 The Qt Company Ltd.
## Contact: http://www.qt.io/licensing/
##
## This file is part of the test suite of the Qt Toolkit.
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

# It also runs update for SDK API level 18, latest SDK tools, latest platform-tools and build-tools version 23.0.3

# Build-tools version 23.0.3 is the latest usable version for Red Hat 6. Newer version of build-tools, version 24.x.x, requires GLIBC_2.14, which is not available in Red Hat 6.

# Android 16 is the minimum requirement for Qt 5.7 applications, but we need something more recent than that for building Qt itself.
# E.g The Bluetooth features that require Android 18 will disable themselves dynamically when running on an Android 16 device.
# That's why we need to use Andoid-18 API version and decision was made to use it also with Qt 5.6.

set -e
targetFolder="/opt/android"
baseUrl="http://ci-files01-hki.intra.qt.io/input/android"

# SDK
sdkPackage="android-sdk_r24.4.1-linux.tgz"
sdkBuildToolsVersion="23.0.3"
sdkApiLevel="android-18"
sdkUrl="$baseUrl/$sdkPackage"
sdkSha1="725bb360f0f7d04eaccff5a2d57abdd49061326d"
sdkTargetFile="$targetFolder/$sdkPackage"
sdkExtract="tar -C $targetFolder -zxf $sdkTargetFile"
sdkFolderName="android-sdk-linux"
sdkName="sdk"

# NDK
ndkVersion="r10e"
ndkPackage="android-ndk-$ndkVersion-linux-x86_64.zip"
ndkUrl="$baseUrl/$ndkPackage"
ndkSha1="f692681b007071103277f6edc6f91cb5c5494a32"
ndkTargetFile="$targetFolder/$ndkPackage"
ndkExtract="unzip $ndkTargetFile -d $targetFolder"
ndkFolderName="android-ndk-$ndkVersion"
ndkName="ndk"

function InstallAndroidPackage {
    targetFolder=$1
    version=$2
    url=$3
    sha1=$4
    targetFile=$5
    extract=$6
    folderName=$7
    name=$8

    sudo wget --tries=5 --waitretry=5 --output-document="$targetFile" "$url" || echo "Failed to download '$url' multiple times"
    echo "$sha1  $targetFile" | sha1sum --check || echo "Failed to check sha1sum"
    sudo chmod 755 "$targetFile"
    sudo $extract || echo "Failed to extract $url"
    sudo chown -R qt:users "$targetFolder"/"$folderName"
    sudo mv "$targetFolder"/"$folderName" "$targetFolder"/"$name" || echo "Failed to rename $name"
    sudo rm -fr "$targetFolder"/"$version"
}

if [ -d "$targetFolder" ]; then
    echo "Removing old Android installation"
    sudo rm -fr "$targetFolder" || ( echo "Can't remove $targetFolder" ; exit 1; )
fi

sudo mkdir "$targetFolder" || ( echo "Can't create $targetFolder" ; exit 1; )

# Install Android SDK
echo "Installing Android SDK version $sdkPackage..."
InstallAndroidPackage "$targetFolder" $sdkPackage $sdkUrl $sdkSha1 $sdkTargetFile "$sdkExtract" $sdkFolderName $sdkName

# Install Android NDK
echo "Installing Android NDK version $ndkPackage..."
InstallAndroidPackage "$targetFolder" $ndkPackage $ndkUrl $ndkSha1 $ndkTargetFile "$ndkExtract" $ndkFolderName $ndkName

# run update for Android SDK and install SDK API version 18, latest SDK tools, platform-tools and build-tools
echo "Running Android SDK update for API version 18, SDK-tools, platform-tools and build-tools-$sdkBuildToolsVersion..."
echo "y" |"$targetFolder"/sdk/tools/android update sdk --no-ui --all --filter $sdkApiLevel,tools,platform-tools,build-tools-$sdkBuildToolsVersion || echo "Failed to run update"

# For Qt 5.6, we by default require API levels 10, 11, 16 and 18, but we can override this by setting ANDROID_API_VERSION=android-18
# From Qt 5.7 forward, if android-16 is not installed, Qt will automatically use more recent one.
echo 'export ANDROID_API_VERSION=android-18' >> ~/.bashrc

# Storage version information to ~/versions.txt, which is used to print version information to provision log.
echo "***** Android SDK *****" >> ~/versions.txt
echo "Android SDK Api Level = $sdkApiLevel" >> ~/versions.txt
echo "Android SDK Build Tools Version = $sdkBuildToolsVersion" >> ~/versions.txt
platformTools="$(grep Pkg.Revision "$targetFolder"/sdk/platform-tools/source.properties | cut -c14-)"
echo "Android Platform Tools = $platformTools" >> ~/versions.txt
sdkTools="$(grep Pkg.Revision "$targetFolder"/sdk/tools/source.properties | cut -c14-)"
echo "Android SDK Tools = $sdkTools" >> ~/versions.txt
echo "***** Android NDK *****" >> ~/versions.txt
echo "Android NDK Version = $ndkVersion" >> ~/versions.txt

