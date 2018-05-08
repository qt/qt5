. "$PSScriptRoot\..\common\windows\install-mingw.ps1"

# This script will install 64-bit MinGW 7.3.0

$release = "x86_64-7.3.0-release-posix-seh-rt_v5-rev0"
$sha1    = "0fce15036400568babd10d65b247e9576515da2c"

InstallMinGW $release $sha1

