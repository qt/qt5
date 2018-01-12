. "$PSScriptRoot\..\common\windows\install-mingw.ps1"

# This script will install 64-bit MinGW 6.3.0

$release = "x86_64-6.3.0-release-posix-seh-rt_v5-rev2"
$sha1    = "49E7F8997E3D15C75B1A4DE1C380ABE1FB9B7533"

InstallMinGW $release $sha1
