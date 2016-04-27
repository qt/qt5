. "$PSScriptRoot\helpers.ps1"

$zip = "c:\users\qt\downloads\jom_1_1_0.zip"

Invoke-WebRequest -UseBasicParsing http://download.qt.io/official_releases/jom/jom_1_1_0.zip -OutFile $zip
Verify-Checksum $zip "C4149FE706B25738B4C4E54C73E180B9CAB55832"
Extract-Zip $zip C:\Utils\Jom
