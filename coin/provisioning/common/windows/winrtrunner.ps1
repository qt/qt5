. "$PSScriptRoot\helpers.ps1"

$zip = "c:\users\qt\downloads\winrtrunner.zip"
$url = "http://download.qt.io/development_releases/prebuilt/winrtrunner/winrtrunner.zip"

Download $url $url $zip
Verify-Checksum $zip "C19098A4C9DBD20EDEB4E5E0D3E6A5BBBCA73C42"
Extract-Zip $zip C:\Utils\winrtrunner
Remove-Item -Path $zip

Set-EnvironmentVariable "CI_WINRTRUNNER_PATH" "C:\Utils\winrtrunner"
