. "$PSScriptRoot\..\common\windows\install-mingw.ps1"

# This script will install MinGW 5.3.0

$release = "i686-5.3.0-release-posix-dwarf-rt_v4-rev0"
$sha1 = "D4F21D25F3454F8EFDADA50E5AD799A0A9E07C6A"

InstallMinGW $release $sha1


