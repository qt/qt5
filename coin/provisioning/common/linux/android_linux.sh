#!/usr/bin/env bash
# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script install Android sdk and ndk.

# It also runs update for SDK API, latest SDK tools, latest platform-tools and build-tools version

set -e

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

toolsVersion="2.1"
toolsFile="commandlinetools-linux-6609375_latest.zip"
sdkBuildToolsVersion="35.0.1"
sdkApiLevel="android-35"
toolsSha1="9172381ff070ee2a416723c1989770cf4b0d1076"

ndkVersionLatest="r27c"
ndkSha1Latest="090e8083a715fdb1a3e402d0763c388abb03fb4e"

# Preview NDK that is in alpha/beta/RC state
ndkVersionPreview="r29-beta2"
ndkSha1Preview="06c29d6764526fb51407d08fcead41247ddd3b70"

# Non-latest (but still supported by the qt/qt5 branch) NDKs are installed for nightly targets in:
# coin/platform_configs/nightly_android.yaml

ndkVersionNightly1=$ndkVersionLatest  # Set as same version as latest = skip NDK install in provisioning
ndkSha1Nightly1=$ndkSha1Latest

ndkVersionNightly2=$ndkVersionLatest
ndkSha1Nightly2=$ndkSha1Latest

# Android Automotive max SDK level image
sdkApiLevelAutomotiveMax="android-34"
androidAutomotiveMaxUrl="$basePath/${sdkApiLevelAutomotiveMax}_automotive.tar.gz"
androidAutomotiveMaxSha="2cc5dae4fd0bdefb188a3b84019d0d1e65501519"
# Android Automotive min SDK level image
sdkApiLevelAutomotiveMin="android-29"
androidAutomotiveMinUrl="$basePath/${sdkApiLevelAutomotiveMin}_automotive.tar.gz"
androidAutomotiveMinSha="e6092585c00f87eb3b20a2eb7fdf6add42342d2f"

toolsTargetFile="/tmp/$toolsFile"
toolsSourceFile="$basePath/$toolsFile"

echo "Download and unzip Android SDK"
DownloadURL "$toolsSourceFile" "$toolsSourceFile" "$toolsSha1" "$toolsTargetFile"
echo "Unzipping Android Tools to '$sdkTargetFolder'"
sudo unzip -q "$toolsTargetFile" -d "$sdkTargetFolder"
rm "$toolsTargetFile"

function InstallNdk() {

    ndkVersion=$1
    ndkSha1=$2

    ndkFile="android-ndk-$ndkVersion-linux.zip"
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

# To be used by vcpkg
SetEnvVar "ANDROID_NDK_HOME" "$targetFolder/android-ndk-$ndkVersionLatest"
export ANDROID_NDK_HOME="$targetFolder/android-ndk-$ndkVersionLatest"

echo "Changing ownership of Android files."
if uname -a |grep -q "el7"; then
    sudo chown -R qt:wheel "$targetFolder"
else
    sudo chown -R qt:users "$targetFolder"
fi

# Stop the sdkmanager from printing thousands of lines of #hashmarks.
# Run the following command under `eval` or `sh -c` so that the shell properly splits it.
sdkmanager_no_progress_bar_cmd="tr '\r' '\n'  |  grep -v '^\[[ =]*\]'"
# But don't let the pipeline hide sdkmanager failures.
set -o pipefail

sudo mkdir "$sdkTargetFolder/cmdline-tools"
sudo mv "$sdkTargetFolder/tools" "$sdkTargetFolder/cmdline-tools"

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
SetEnvVar "ANDROID_NDK_HOST" "linux-x86_64"
SetEnvVar "ANDROID_API_VERSION" "$sdkApiLevel"

# shellcheck disable=SC2129
cat >>~/versions.txt <<EOB
Android SDK tools = $toolsVersion
Android SDK Build Tools = $sdkBuildToolsVersion
Android SDK API level = $sdkApiLevel
Android NDK = $ndkVersion
EOB

cd "$sdkTargetFolder/cmdline-tools/tools/bin"
./sdkmanager --install "emulator" --sdk_root="$sdkTargetFolder" \
    | eval "$sdkmanager_no_progress_bar_cmd"

echo "Download and unzip Android Emulator version 35.2.10"
emulatorFileName="emulator-linux_x64-12414864.zip"
emulatorCiUrl="https://ci-files01-hki.ci.qt.io/input/android/$emulatorFileName"
emulatorUrl="http://dl.google.com/android/repository/$emulatorFileName"
emulatorTargetFile="$sdkTargetFolder/$emulatorFileName"
emulatorSha1="41dd213d120f727d8c3840347d234b135793ba10"
DownloadURL "$emulatorCiUrl" "$emulatorUrl" "$emulatorSha1" "$emulatorTargetFile"
echo "Unzipping the Android Emulator to '$sdkTargetFolder'"
sudo unzip -o -q "$emulatorTargetFile" -d "$sdkTargetFolder"
rm "$emulatorTargetFile"

echo "Download and unzip Android 9 System Image"
minVersionFileName="x86-28_r08.zip"
minVersionDestination="$sdkTargetFolder/system-images/android-28/google_apis/"
minVersionFilePath="$minVersionDestination/$minVersionFileName"
minVersionCiUrl="$basePath/system_images/google_apis/$minVersionFileName"
minVersionUrl="https://dl.google.com/android/repository/sys-img/google_apis/$minVersionFileName"
minVersionSha1="41e3b854d7987a3d8b7500631dae1f1d32d3db4e"

mkdir -p "$minVersionDestination"
DownloadURL "$minVersionCiUrl" "$minVersionUrl" "$minVersionSha1" "$minVersionFilePath"

echo "Unzipping the Android 9 to $minVersionDestination"
sudo unzip -o -q "$minVersionFilePath" -d "$minVersionDestination"
rm "$minVersionFilePath"

echo "Download and unzip Android 15 System Image"
maxVersionFileName="x86_64-35_r08.zip"
maxVersionDestination="$sdkTargetFolder/system-images/android-35/google_apis/"
maxVersionFilePath="$maxVersionDestination/$maxVersionFileName"
maxVersionCiUrl="$basePath/system_images/google_apis/$maxVersionFileName"
maxVersionUrl="https://dl.google.com/android/repository/sys-img/google_apis/$maxVersionFileName"
maxVersionSha1="d79169884cabc6680cb29d32c2112ad46c858c1b"

mkdir -p "$maxVersionDestination"
DownloadURL "$maxVersionCiUrl" "$maxVersionUrl" "$maxVersionSha1" "$maxVersionFilePath"

echo "Unzipping the Android 15 to $maxVersionDestination"
sudo unzip -o -q "$maxVersionFilePath" -d "$maxVersionDestination"
rm "$maxVersionFilePath"

echo "Download and unzip Android 16 System Image for insignificant"
insignificantMaxVersionFileName="x86_64-36_r06.zip"
insignificantMaxVersionDestination="$sdkTargetFolder/system-images/android-36/google_apis/"
insignificantMaxVersionFilePath="$insignificantMaxVersionDestination/$insignificantMaxVersionFileName"
insignificantMaxVersionCiUrl="$basePath/system_images/google_apis/$insignificantMaxVersionFileName"
insignificantMaxVersionUrl="https://dl.google.com/android/repository/sys-img/google_apis/$insignificantMaxVersionFileName"
insignificantMaxVersionSha1="a9b0b4a0488e0c6c380f5485507950f011388511"

mkdir -p "$insignificantMaxVersionDestination"
DownloadURL "$insignificantMaxVersionCiUrl" "$insignificantMaxVersionUrl" "$insignificantMaxVersionSha1" "$insignificantMaxVersionFilePath"

echo "Unzipping the Android 16 insignicant to $insignificantMaxVersionDestination"
sudo unzip -o -q "$insignificantMaxVersionFilePath" -d "$insignificantMaxVersionDestination"
rm "$insignificantMaxVersionFilePath"

echo "Checking the contents of Android SDK again..."
ls -l "$sdkTargetFolder"

echo "no" | ./avdmanager create avd -n emulator_x86_api_28 -c 2048M -f \
    -k "system-images;android-28;google_apis;x86"

echo "no" | ./avdmanager create avd -n emulator_x86_64_api_35 -c 2048M -f \
    -k "system-images;android-35;google_apis;x86_64"

echo "no" | ./avdmanager create avd -n emulator_x86_64_api_36 -c 2048M -f \
    -k "system-images;android-36;google_apis;x86_64"

echo "Install maximum supported SDK level image for Android Automotive $sdkApiLevelAutomotiveMax"
DownloadURL "$androidAutomotiveMaxUrl" "$androidAutomotiveMaxUrl" "$androidAutomotiveMaxSha" \
    "/tmp/${sdkApiLevelAutomotiveMax}_automotive.tar.gz"
sudo tar -xzf "/tmp/${sdkApiLevelAutomotiveMax}_automotive.tar.gz" -C "$sdkTargetFolder/system-images"
echo "no" | ./avdmanager create avd -n automotive_emulator_x86_64_api_34 -c 2048M -f \
    -k "system-images;${sdkApiLevelAutomotiveMax};android-automotive;x86_64"

echo "Install minimum supported SDK level image for Android Automotive $sdkApiLevelAutomotiveMin"
DownloadURL "$androidAutomotiveMinUrl" "$androidAutomotiveMinUrl" "$androidAutomotiveMinSha" \
    "/tmp/${sdkApiLevelAutomotiveMin}_automotive.tar.gz"
sudo tar -xzf "/tmp/${sdkApiLevelAutomotiveMin}_automotive.tar.gz" -C $sdkTargetFolder/system-images
echo "no" | ./avdmanager create avd -n automotive_emulator_x86_64_api_29 -c 2048M -f \
    -k "system-images;${sdkApiLevelAutomotiveMin};android-automotive;x86_64"

# Purely informative, show the list of avd devices
./avdmanager list avd

# To be used by the VMs to start the emulator for tests
emulator_script_filename="android_emulator_launcher.sh"
scripts_dir_name="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
cp "${scripts_dir_name}/${emulator_script_filename}" "${HOME}"
ANDROID_EMULATOR_RUNNER="${HOME}/${emulator_script_filename}"
SetEnvVar "ANDROID_EMULATOR_RUNNER" "$ANDROID_EMULATOR_RUNNER"

# Gradle Caching
cp -r "${scripts_dir_name}/android/gradle_project" /tmp/gradle_project
cd /tmp/gradle_project
# Get Gradle files from qtbase
qtbaseGradleUrl="https://code.qt.io/cgit/qt/qtbase.git/plain/src/3rdparty/gradle"
commit_sha="bb12c984b2c838bdb06169ef7d659384c02c8b82"
curl "$qtbaseGradleUrl/gradle.properties?h=$commit_sha" > gradle.properties
curl "$qtbaseGradleUrl/gradlew?h=$commit_sha" > gradlew
curl "$qtbaseGradleUrl/gradlew.bat?h=$commit_sha" > gradlew.bat
mkdir -p gradle/wrapper
curl "$qtbaseGradleUrl/gradle/wrapper/gradle-wrapper.jar?h=$commit_sha" > gradle/wrapper/gradle-wrapper.jar
curl "$qtbaseGradleUrl/gradle/wrapper/gradle-wrapper.properties?h=$commit_sha" > gradle/wrapper/gradle-wrapper.properties
# Run Gradle
chmod +x gradlew
ANDROID_SDK_ROOT="$sdkTargetFolder" sh gradlew build
