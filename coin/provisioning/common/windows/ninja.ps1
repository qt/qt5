. "$PSScriptRoot\helpers.ps1"

$zip = Get-DownloadLocation "ninja-1.10.2-win-x86.zip"

Download http://master.qt.io/development_releases/prebuilt/ninja/v1.10.2/ninja-win-x86.zip \\ci-files01-hki.ci.qt.io\provisioning\ninja\ninja-1.10.2-win-really-x86.zip $zip
Verify-Checksum $zip "1a22ee9269df8ed69c4600d7ee4ccd8841bb99ca"

Extract-7Zip $zip C:\Utils\Ninja
Remove "$zip"

Add-Path "C:\Utils\Ninja"

Write-Output "Ninja = 1.10.2" >> ~/versions.txt


$manifest = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly manifestVersion="1.0" xmlns="urn:schemas-microsoft-com:asm.v1">
  <application>
    <windowsSettings>
      <activeCodePage xmlns="http://schemas.microsoft.com/SMI/2019/WindowsSettings">UTF-8</activeCodePage>
      <longPathAware  xmlns="http://schemas.microsoft.com/SMI/2016/WindowsSettings">true</longPathAware>
    </windowsSettings>
  </application>
</assembly>
"@


$vs2019 = [System.IO.File]::Exists("C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat")

if($vs2019) {
Invoke-MtCommand "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat" amd64 $manifest "C:\Utils\Ninja\ninja.exe"
} else {
Invoke-MtCommand "C:\Program Files (x86)\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat" amd64 $manifest "C:\Utils\Ninja\ninja.exe"
}
