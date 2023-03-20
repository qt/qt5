. "$PSScriptRoot\helpers.ps1"

$zip = Get-DownloadLocation "winrtrunner.zip"
$url = "http://download.qt.io/development_releases/prebuilt/winrtrunner/winrtrunner_2018-07-06.zip"
$url_cache = "\\ci-files01-hki.ci.qt.io\provisioning\windows\winrtrunner\winrtrunner_2018-07-06.zip"

Download $url $url_cache $zip
Verify-Checksum $zip "93548e8c3fb8fded2474996ef5e0163f489ce8cf"
Extract-7Zip $zip C:\Utils\winrtrunner
Remove "$zip"

Set-EnvironmentVariable "CI_WINRTRUNNER_PATH" "C:\Utils\winrtrunner"
