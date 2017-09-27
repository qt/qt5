. "$PSScriptRoot\..\common\install-mingw.ps1"

# This script will install MinGW 6.3.0

$release = "i686-6.3.0-release-posix-dwarf-rt_v5-rev2"
$sha1    = "AABEFF22DC3800FCFDB29144BFB08B0B728C476B"

InstallMinGW $release $sha1
