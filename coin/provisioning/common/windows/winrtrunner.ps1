. "$PSScriptRoot\helpers.ps1"

$zip = "c:\users\qt\downloads\winrtrunner.zip"

Invoke-WebRequest -UseBasicParsing http://download.qt.io/development_releases/prebuilt/winrtrunner/winrtrunner.zip -OutFile $zip
Verify-Checksum $zip "C19098A4C9DBD20EDEB4E5E0D3E6A5BBBCA73C42"
Extract-Zip $zip C:\Utils\winrtrunner
Remove-Item $zip

[Environment]::SetEnvironmentVariable("CI_WINRTRUNNER_PATH", "C:\Utils\winrtrunner", "Machine")
