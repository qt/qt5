. "$PSScriptRoot\..\common\windows\install-mingw.ps1"

# This script will install 64-bit MinGW 8.1.0

$release = "x86_64-8.1.0-release-posix-seh-rt_v6-rev0"

$sha1    = "5aa456654a6ce77249c27888b5d0f856fc011b9c"

InstallMinGW $release $sha1

