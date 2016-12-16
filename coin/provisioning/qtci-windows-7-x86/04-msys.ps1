. "$PSScriptRoot\..\common\helpers.ps1"

# This script will install msys which is needed for configuring openssl for Android

$version = "1.0.11"
$url = "http://ci-files01-hki.ci.local/input/windows/msys-$version.7z"

$zip = "c:\users\qt\downloads\msys-$version.7z"
$sha1 = "22cd76f1263db8c72727a9537228c481ff33c285"
$destination = "C:\msys"

Download $url $url $zip
Verify-Checksum $zip $sha1
C:\Utils\sevenzip\7z.exe x $zip -oC:\
