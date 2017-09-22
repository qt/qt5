. "$PSScriptRoot\..\common\install-mingw.ps1"

# This script will install MinGW 6.3.0

$version = "6.3.0"
$release = "release-posix-dwarf-rt_v5-rev2"

InstallMinGW $version $release
