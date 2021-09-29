. "$PSScriptRoot\..\common\windows\install-mingw.ps1"

# This script will install 64-bit MinGW 11.2.0
# Note! MinGW version is 9.0.0 but the GCC version is 11.2 which is used with the naming of MinGW

$release = "mingw-w64-x86_64-11.2.0-release-posix-seh-rt_v9-rev1"

$sha1    = "5554791dc13468bf44e2e519c6691f2deecd000c"

InstallMinGW $release $sha1

