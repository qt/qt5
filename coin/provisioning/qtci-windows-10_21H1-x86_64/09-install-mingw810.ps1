. "$PSScriptRoot\..\common\windows\install-mingw.ps1"

# This script will install MinGW 8.1.0

$release = "i686-8.1.0-release-posix-dwarf-rt_v6-rev0"
$sha1 = "dd4f34f473e84c79b6b446adb3a5fac7919ba9cb"
$suffix = "_i686"

InstallMinGW $release $sha1 $suffix


