. "$PSScriptRoot\..\common\windows\install-mingw.ps1"

# This script will install MinGW 7.3.0

$release = "i686-7.3.0-release-posix-dwarf-rt_v5-rev0"
$sha1 = "96e11c754b379c093e1cb3133f71db5b9f3e0532"

InstallMinGW $release $sha1


