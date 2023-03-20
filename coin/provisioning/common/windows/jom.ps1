. "$PSScriptRoot\helpers.ps1"

$version = "1_1_2"
$zip = Get-DownloadLocation "jom_$version.zip"

Download http://download.qt.io/official_releases/jom/jom_$version.zip http://ci-files01-hki.ci.qt.io/input/windows/jom_$version.zip $zip
Verify-Checksum $zip "80EE5678E714DE99DDAF5F7593AB04DB1C7928E4"
Extract-7Zip $zip C:\Utils\Jom

Set-EnvironmentVariable "CI_JOM_PATH" "C:\Utils\Jom"

$version = $version.replace('_','.')
Write-Output "Jom = $version" >> ~/versions.txt
