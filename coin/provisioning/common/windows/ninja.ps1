. "$PSScriptRoot\helpers.ps1"

$cpu_arch = Get-CpuArchitecture
switch ($cpu_arch) {
    arm64 {
        $arch = "arm64"
        $version = "1.12.0"
        $longPathFixed = $true # fixed https://github.com/ninja-build/ninja/pull/2225 in 1.12.0
        $zip = Get-DownloadLocation "ninja-$version-win-$arch.zip"
        $internalUrl = "https://ci-files01-hki.ci.qt.io/input/ninja/ninja-$version-win-$arch.zip"
        $externalUrl = "https://github.com/ninja-build/ninja/releases/download/v$version/ninja-win$arch.zip"
        $sha1 = "51bf1bac149ae1e3d1572fa9fa87d6431dbddc8b"
        Break
    }
    x64 {
        $arch = "amd64"
        $version = "1.10.2"
        $longPathFixed = $false
        $zip = Get-DownloadLocation "ninja-$version-win-x86.zip"
        $internalUrl = "https://ci-files01-hki.ci.qt.io/input/ninja/ninja-$version-win-really-x86.zip"
        $externalUrl = "http://master.qt.io/development_releases/prebuilt/ninja/v$version/ninja-win-x86.zip"
        $sha1 = "1a22ee9269df8ed69c4600d7ee4ccd8841bb99ca"
        Break
    }
    default {
        throw "Unknown architecture $cpu_arch"
    }
}

Download  $externalUrl $internalUrl $zip
Verify-Checksum $zip $sha1
Extract-7Zip $zip C:\Utils\Ninja
Remove "$zip"

Add-Path "C:\Utils\Ninja"

Write-Output "Ninja ($arch) = $version" >> ~/versions.txt

if ( -Not $longPathFixed ) {

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

Set-EnvironmentVariable "NINJA_EXECUTABLE" "C:\Utils\Ninja\ninja.exe"

$vs2019 = [System.IO.File]::Exists("C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat")

if($vs2019) {
Invoke-MtCommand "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat" amd64 $manifest "C:\Utils\Ninja\ninja.exe"
} else {
Invoke-MtCommand "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat" amd64 $manifest "C:\Utils\Ninja\ninja.exe"
}

}
