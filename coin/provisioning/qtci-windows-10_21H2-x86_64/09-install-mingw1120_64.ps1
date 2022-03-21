. "$PSScriptRoot\..\common\windows\install-mingw.ps1"

# This script will install 64-bit MinGW 11.2.0
# Note! MinGW version is 9.0.0 but the GCC version is 11.2 which is used with the naming of MinGW

$release = "MinGW-w64-x86_64-11.2.0-release-posix-seh-rt_v9-rev3"

$sha1    = "50174112ceca6f9fe42debbedda54ce6e9187302"

InstallMinGW $release $sha1

