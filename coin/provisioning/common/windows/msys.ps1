. "$PSScriptRoot\helpers.ps1"

# This script will install msys which is needed for configuring openssl for Android

$version = "1.0.11"
$url = "\\ci-files01-hki.ci.qt.io\provisioning\windows\msys-$version.7z"

$zip = Get-DownloadLocation ("msys-$version.7z")
$sha1 = "22cd76f1263db8c72727a9537228c481ff33c285"
$destination = "C:\msys"

Download $url $url $zip
Verify-Checksum $zip $sha1
Extract-7Zip $zip C:\
Set-EnvironmentVariable "MSYS_PATH" "$destination\\1.0\\bin"
Write-Output "Msys = $version" >> ~/versions.txt
