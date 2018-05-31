. "$PSScriptRoot\helpers.ps1"

$zip = Get-DownloadLocation "ninja-1.6.0-win-x86.zip"

Download https://github.com/ninja-build/ninja/releases/download/v1.6.0/ninja-win.zip \\ci-files01-hki.intra.qt.io\provisioning\ninja\ninja-1.6.0-win-x86.zip $zip
Verify-Checksum $zip "E01093F6533818425F8EFB0843CED7DCAABEA3B2"

Extract-7Zip $zip C:\Utils\Ninja
Remove-Item -Path $zip

Add-Path "C:\Utils\Ninja"

Write-Output "Ninja = 1.6.0" >> ~/versions.txt
