############################################################################
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

. "$PSScriptRoot\..\common\helpers.ps1"

# This script installs Android sdk and ndk
# It also runs update for SDK API level 21, latest SDK tools, latest platform-tools and build-tools version $sdkBuildToolsVersion
# Android 16 is the minimum requirement for Qt 5.7 applications, but we need something more recent than that for building Qt itself.
# E.g The Bluetooth features that require Android 21 will disable themselves dynamically when running on an Android 16 device.
# That's why we need to use Andoid-21 API version in Qt 5.9.

# NDK
$ndkVersion = "r10e"
$ndkCachedUrl = "\\ci-files01-hki.intra.qt.io\provisioning\android\android-ndk-$ndkVersion-windows-x86.zip"
$ndkOfficialUrl = "https://dl.google.com/android/repository/android-ndk-$ndkVersion-windows-x86.zip"
$ndkChecksum = "1d0b8f2835be741f3048fb03c0a3e9f71ab7f357"
$ndkFolder = "c:\utils\android-ndk-$ndkVersion"
$ndkZip = "c:\Windows\Temp\android_ndk_$ndkVersion.zip"

# SDK
$sdkVersion = "r24.4.1"
$sdkApi = "ANDROID_API_VERSION"
$sdkApiLevel = "android-21"
$sdkBuildToolsVersion = "23.0.3"
$sdkCachedUrl= "\\ci-files01-hki.intra.qt.io\provisioning\android\android-sdk_$sdkVersion-windows.zip"
$sdkOfficialUrl = "https://dl.google.com/android/android-sdk_$sdkVersion-windows.zip"
$sdkChecksum = "66b6a6433053c152b22bf8cab19c0f3fef4eba49"
$sdkFolder = "c:\utils\android-sdk-windows"
$sdkZip = "c:\Windows\Temp\android_sdk_$sdkVersion.zip"

function Install($1, $2, $3, $4) {
    $cacheUrl = $1
    $zip = $2
    $checksum = $3
    $offcialUrl = $4

    Download $offcialUrl $cacheUrl $zip
    Verify-Checksum $zip "$checksum"
    Extract-Zip $zip C:\Utils
}

function SdkUpdate ($1, $2) {
    echo "Running Android SDK update for $1..."
    cmd /c "echo y |$1\tools\android update sdk --no-ui --all --filter $2"
}

echo "Installing Android ndk $nkdVersion"
Install $ndkCachedUrl $ndkZip $ndkChecksum $ndkOfficialUrl
echo "Set environment variable ANDROID_NDK_HOME=$ndkFolder"
[Environment]::SetEnvironmentVariable("ANDROID_NDK_HOME", $ndkFolder, "Machine")
echo "Set environment variable ANDROID_NDK_ROOT=$ndkFolder"
[Environment]::SetEnvironmentVariable("ANDROID_NDK_ROOT", $ndkFolder, "Machine")

#echo "Installing Android sdk $sdkVersion"
Install $sdkCachedUrl $sdkZip $sdkChecksum $sdkOfficialUrl
echo "Set environment variable ANDROID_SDK_HOME=$sdkFolder"
[Environment]::SetEnvironmentVariable("ANDROID_SDK_HOME", $sdkFolder, "Machine")
echo "Set environment variable ANDROID_API_VERSION $sdkApiLevel"
[Environment]::SetEnvironmentVariable("ANDROID_API_VERSION", $sdkApiLevel, "Machine")

# SDK update
SdkUpdate $sdkFolder $sdkApiLevel
SdkUpdate $sdkFolder tools
SdkUpdate $sdkFolder platform-tools
SdkUpdate $sdkFolder build-tools-$sdkBuildToolsVersion

# kill adb. This process prevent's provisioning to continue
taskkill /im adb.exe /f
