. "$PSScriptRoot\..\common\windows\install-mingw.ps1"

# This script will install 64-bit MinGW 15.1.0
# Note! MinGW version is 12.0.0 but the GCC version is 15.1 which is used with the naming of MinGW

$release = "MinGW-w64-x86_64-15.1.0-release-posix-seh-msvcrt-rt_v12-rev0"

$sha1    = "2fbec5f4a0e46099a850b11780500d0208b10591"

InstallMinGW $release $sha1

