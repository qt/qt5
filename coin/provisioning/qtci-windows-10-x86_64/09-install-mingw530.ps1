. "$PSScriptRoot\..\common\install-mingw.ps1"

# This script will install MinGW 5.3.0

$version = "5.3.0"
$release = "release-posix-dwarf-rt_v4-rev0"

InstallMinGW $version $release


