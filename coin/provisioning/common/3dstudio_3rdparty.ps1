. "$PSScriptRoot\helpers.ps1"

$zip = "c:\users\qt\downloads\Qt3DStudio-3rdparty-win64-CI.zip"

Invoke-WebRequest -UseBasicParsing http://ci-files01-hki.ci.local/input/3rdparty/Qt3DStudio-3rdparty-win64-CI.zip -OutFile $zip
Verify-Checksum $zip "08D740D2EFB4CBCDE7D012908B89AA48DE5CD4E1"
Extract-Zip $zip C:\Utils\Qt3DStudio3rdparty
Remove-Item $zip

[Environment]::SetEnvironmentVariable("QT3DSTUDIO_3RDPARTY_DIR", "C:/Utils/Qt3DStudio3rdparty", "Machine")
