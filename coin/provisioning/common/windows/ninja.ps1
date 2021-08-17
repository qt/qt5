. "$PSScriptRoot\helpers.ps1"

$zip = Get-DownloadLocation "ninja-1.10.2-win-x86.zip"

Download http://master.qt.io/development_releases/prebuilt/ninja/v1.10.2/ninja-win-x86.zip \\ci-files01-hki.intra.qt.io\provisioning\ninja\ninja-1.10.2-win-really-x86.zip $zip
Verify-Checksum $zip "1a22ee9269df8ed69c4600d7ee4ccd8841bb99ca"

Extract-7Zip $zip C:\Utils\Ninja
Remove "$zip"

Add-Path "C:\Utils\Ninja"

Write-Output "Ninja = 1.10.2" >> ~/versions.txt
