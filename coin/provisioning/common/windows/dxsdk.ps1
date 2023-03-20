. "$PSScriptRoot\helpers.ps1"

# This script installs DirectX SDK

$package = "DXSDK_Jun10.exe"

$cachedUrl = "\\ci-files01-hki.ci.qt.io\provisioning\windows\$package"
$officialUrl = "https://download.microsoft.com/download/A/E/7/AE743F1F-632B-4809-87A9-AA1BB3458E31/$package"
$sdkChecksumSha1 = "8fe98c00fde0f524760bb9021f438bd7d9304a69"
$package_path = "C:\Windows\Temp\$package"

Download $officialUrl $cachedUrl $package_path
Verify-Checksum $package_path $sdkChecksumSha1 sha1
Write-Host "Installing DirectX SDK"
Run-Executable $package_path "/u"

Remove "$package_path"

Write-Output "DirectX SDK = 9.29.1962 (Jun 10)" >> ~\versions.txt
