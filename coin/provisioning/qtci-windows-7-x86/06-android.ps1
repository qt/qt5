. "$PSScriptRoot\..\common\helpers.ps1"

# This script installs Android sdk and ndk
# It also runs update for SDK API level 18, latest SDK tools, latest platform-tools and build-tools version $sdkBuildToolsVersion
# Android 16 is the minimum requirement for Qt 5.7 applications, but we need something more recent than that for building Qt itself.
# E.g the bluetooth features that require Android 18 will disable themselves dynamically when running on Android 16 device.
# That's why we need to use Andoid-18 API version and decision was made to use it also with Qt 5.6.

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
$sdkApiLevel = "android-18"
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
