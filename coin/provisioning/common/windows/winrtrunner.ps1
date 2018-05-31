. "$PSScriptRoot\helpers.ps1"

$zip = Get-DownloadLocation "winrtrunner.zip"
$url = "http://download.qt.io/development_releases/prebuilt/winrtrunner/winrtrunner_2018-05-24.zip"
$url_cache = "\\ci-files01-hki.intra.qt.io\provisioning\windows\winrtrunner\winrtrunner_2018-05-24.zip"

Download $url $url_cache $zip
Verify-Checksum $zip "b83f2166b5799910a661d1db02771edf94880785"
Extract-7Zip $zip C:\Utils\winrtrunner
Remove-Item -Path $zip

Set-EnvironmentVariable "CI_WINRTRUNNER_PATH" "C:\Utils\winrtrunner"
