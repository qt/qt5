. "$PSScriptRoot\helpers.ps1"

$zip = "c:\users\qt\downloads\jom_1_1_2.zip"

Invoke-WebRequest -UseBasicParsing http://download.qt.io/official_releases/jom/jom_1_1_2.zip -OutFile $zip
Verify-Checksum $zip "80EE5678E714DE99DDAF5F7593AB04DB1C7928E4"
Extract-Zip $zip C:\Utils\Jom

[Environment]::SetEnvironmentVariable("CI_JOM_PATH", "C:\Utils\Jom", "Machine")
