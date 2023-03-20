. "$PSScriptRoot\helpers.ps1"

$zip = Get-DownloadLocation "Qt3DStudio-3rdparty-win64-CI.zip"

$url = "http://ci-files01-hki.ci.qt.io/input/3rdparty/Qt3DStudio-3rdparty-win64-CI.zip"

Download $url $url $zip
Verify-Checksum $zip "08D740D2EFB4CBCDE7D012908B89AA48DE5CD4E1"
Extract-7Zip $zip C:\Utils\Qt3DStudio3rdparty
Remove "$zip"

Set-EnvironmentVariable "QT3DSTUDIO_3RDPARTY_DIR" "C:/Utils/Qt3DStudio3rdparty"
