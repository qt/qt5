. "$PSScriptRoot\..\common\windows\install-mingw.ps1"

# This script will install 64-bit MinGW 13.1.0
# Note! MinGW version is 9.0.0 but the GCC version is 13.1 which is used with the naming of MinGW

$release = "MinGW-w64-x86_64-13.1.0-release-posix-seh-msvcrt-rt_v11-rev1"

$sha1    = "561db0989c1b2cb73e0ceb27aed3b0ee8cb1db48"

InstallMinGW $release $sha1

