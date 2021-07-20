. "$PSScriptRoot\helpers.ps1"

$zip = Get-DownloadLocation "ninja-1.10.2-win-x86.zip"

Download https://github.com/ninja-build/ninja/releases/download/v1.10.2/ninja-win.zip \\ci-files01-hki.intra.qt.io\provisioning\ninja\ninja-1.10.2-win-x86.zip $zip
Verify-Checksum $zip "ccacdf88912e061e0b527f2e3c69ee10544d6f8a"

Extract-7Zip $zip C:\Utils\Ninja
Remove "$zip"

Add-Path "C:\Utils\Ninja"

Write-Output "Ninja = 1.10.2" >> ~/versions.txt
