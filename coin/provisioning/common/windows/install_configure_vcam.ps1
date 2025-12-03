# Copyright (C) 2025 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

$script:commitSha    = "a8c4d08c9757c1689d832a33252ae465b97bfb9a"
$script:repoUrl      = "https://git.qt.io/qtmultimedia/WindowsVirtualCamera/-/archive/$commitSha/WindowsVirtualCamera-$commitSha.zip"
$script:unzip_location    = "C:\Utils\WindowsVirtualCamera"
$script:download_location = "C:\Windows\Temp\WindowsVirtualCamera.zip"

$script:nuget = [System.Environment]::GetEnvironmentVariable('NUGET_EXE_PATH', [System.EnvironmentVariableTarget]::Machine)

$script:localPath    = "$unzip_location\WindowsVirtualCamera-$commitSha"
$script:solutionFile = "VCamManager.sln"
$script:buildConfig  = "Release"
$script:targetPlatform = "x64"
$script:dllPath      = "$localPath\$targetPlatform\$buildConfig\VCamSampleSource.dll"

# Save the current location to return later
$previousLocation = Get-Location

Write-Host "Downloading from $repoUrl to $download_location"
Invoke-WebRequest -Uri $repoUrl -OutFile $download_location
Write-Host "Extracting $download_location to $unzip_location"
Expand-Archive -Path $download_location -DestinationPath $unzip_location
Remove-Item $download_location

# Ensure we're inside repo folder
Set-Location $localPath

$hostArch = Get-CpuArchitecture
$arch = $hostArch
$result = EnterVSDevShell -HostArch $hostArch -Arch $arch
if (-Not $result) {
    return $false
}

Write-Host "Locating MSBuild"
$vswhere = "${Env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

if (-not (Test-Path $vswhere)) {
    throw "vswhere.exe not found! Path: $vswhere"
}

$msbuildPath = & $vswhere `
        -latest `
        -products * `
        -requires Microsoft.Component.MSBuild `
        -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
        -find "MSBuild\**\Bin\MSBuild.exe" `

if ($LASTEXITCODE -ne 0 -or -not (Test-Path $msbuildPath)) {
    throw "MSBuild NOT found. Make sure VS Build Tools are installed."
}
Write-Host "MSBuild found: $msbuildPath"

Write-Host "Restoring NuGet packages"
& $nuget restore $solutionFile

Write-Host "Building solution $solutionFile"
& "$msbuildPath" $solutionFile `
    /t:Build `
    /p:Configuration=$buildConfig `
    /p:Platform=$targetPlatform `
    /p:RestorePackagesConfig=true `
    /m

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build succeeded"
} else {
    Write-Host " Build failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}

Write-Host "Registering the Virtual Camera dll"
regsvr32 /s "$dllPath"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Register succeeded"
} else {
    Write-Host "Register failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}

Set-EnvironmentVariable "VCAM_PATH" "$localPath\$targetPlatform\$buildConfig"
Write-Host "Environment variable VCAM_PATH set to $localPath\$targetPlatform\$buildConfig"

# Return to previous location
Set-Location $previousLocation
