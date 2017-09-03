. "$PSScriptRoot\..\common\windows\install-mingw.ps1"

# This script will install MinGW 4.9.2

$release = "i686-4.9.2-release-posix-dwarf-rt_v3-rev1"
$sha1 = "a315254e0e85cfa170939e8c6890a7df1dc6bd20"

InstallMinGW $release $sha1


