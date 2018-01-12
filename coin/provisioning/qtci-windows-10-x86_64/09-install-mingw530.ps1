. "$PSScriptRoot\..\common\windows\install-mingw.ps1"

# This script will install 64-bit MinGW 5.3.0

$release = "x86_64-5.3.0-release-posix-seh-rt_v4-rev0"
$sha1 = "7EB12DD3EDDCF609722C9552F8592BD9948DA1FC"

InstallMinGW $release $sha1


