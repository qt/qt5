# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will update MSVC 2019.
# NOTE! Visual Studio is pre-installed to tier 1 image so this script won't install the whole Visual Studio. See ../../../pre-provisioning/qtci-windows-10-x86_64/msvc2019.txt
# MSVC 2019 online installers can be found from here https://docs.microsoft.com/en-us/visualstudio/releases/2019/history#installing-an-earlier-release

# NOTE! Currenlty Buildtools are not updated. There seems to be an issue with installer. When it's run twice it get stuck and can't be run again. 

$version = "16.11.10"
$urlCache_vsInstaller = "\\ci-files01-hki.ci.qt.io\provisioning\windows\msvc\vs2019_Professional_$version.exe"
$urlOfficial_vsInstaller = "https://download.visualstudio.microsoft.com/download/pr/791f3d28-7e20-45d9-9373-5dcfbdd1f6db/cd440cf67c0cf1519131d1d51a396e44c5b4f7b68b541c9f35c05a310d692f0a/vs_Professional.exe"
$sha1_vsInstaller = "d4f3b3b7dc28dcc3f25474cd1ca1e39fca7dcf3f"
$urlCache_buildToolsInstaller = "\\ci-files01-hki.ci.qt.io\provisioning\windows\msvc\vs2019_BuildTools_$version.exe"
# $urlOfficial_buildToolsInstaller = "https://download.visualstudio.microsoft.com/download/pr/791f3d28-7e20-45d9-9373-5dcfbdd1f6db/d5eabc3f4472d5ab18662648c8b6a08ea0553699819b88f89d84ec42d12f6ad7/vs_BuildTools.exe"
# $sha1_buildToolsInstaller = "69889f45d229de8e0e76b6d9e05964477eee2e78"
$installerPath = "C:\Windows\Temp\installer.exe"

function Install {

    Param (
        [string] $urlOfficial = $(BadParam("Official url path")),
        [string] $urlCache = $(BadParam("Cached url path")),
        [string] $sha1 = $(BadParam("SHA1 checksum of the file"))

    )

    Write-Host "Installing msvc 2019 $version"
    Download $urlOfficial $urlCache $installerPath
    Verify-Checksum $installerPath $sha1
    # We have to update the installer bootstrapper before calling the actual installer.
    # Otherwise installation might fail silently
    Run-Executable "$installerPath" "--quiet --update"
    Run-Executable "$installerPath" "update --passive --wait"
    Remove-Item -Force -Path $installerPath
}

function Get-Vswhere-Property {
    Param (
        [ValidateSet(2017, 2019, 2022)]
        [int] $vsYear = $(BadParam("Visual Studio Year")),

        [ValidatePattern("Professional|Build *Tools|Community|Enterprise")]
        [string] $vsEdition = $(BadParam("Visual Studio Edition")),

        [string] $property = $(BadParam("vswhere property"))
    )

    $range = switch ($vsYear)
    {
        2017 { "[15.0,16`)" }
        2019 { "[16.0,17`)" }
        2022 { "[17.0,18`)" }
    }

    $vsEdition = $vsEdition -replace " ",""

    $vswhereInfo = New-Object System.Diagnostics.ProcessStartInfo
    $vswhereInfo.FileName = "${Env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    $vswhereInfo.RedirectStandardError = $true
    $vswhereInfo.RedirectStandardOutput = $true
    $vswhereInfo.UseShellExecute = $false
    $vswhereInfo.Arguments = "-version $range", "-latest", `
    "-products Microsoft.VisualStudio.Product.$vsEdition", "-property $property"
    $vswhereProcess = New-Object System.Diagnostics.Process
    $vswhereProcess.StartInfo = $vswhereInfo
    $vswhereProcess.Start() | Out-Null
    $vswhereProcess.WaitForExit()
    $stdout = $vswhereProcess.StandardOutput.ReadToEnd()
    if ([string]::IsNullOrEmpty($stdout))
    {
        throw "VS edition or property $property not found by vswhere"
    }
    $stderr = $vswhereProcess.StandardError.ReadToEnd()
    $vsExit = $vswhereProcess.ExitCode
    if ($vsExit -ne 0)
    {
        throw "vswhere failed with exit code $vsExit. stderr: $stderr"
    }
    return $stdout
}

Install $urlOfficial_vsInstaller $urlCache_vsInstaller $sha1_vsInstaller
# Install $urlOfficial_buildToolsInstaller $urlCache_buildToolsInstaller $sha1_buildToolsInstaller

$msvc2019Version = Get-Vswhere-Property 2019 "Professional" catalog_productDisplayVersion
$msvc2019Complete = Get-Vswhere-Property 2019 "Professional" isComplete
$msvc2019Launchable = Get-Vswhere-Property 2019 "Professional" isLaunchable

if($msvc2019Version -ne $version -or [int]$msvc2019Complete -ne 1 `
    -or [int]$msvc2019Launchable -ne 1) {
    throw "MSVC 2019 update failed. msvc2019Version: $($msvc2019Version) `
        msvc2019Complete: $($msvc2019Complete) msvc2019Launchable: $($msvc2019Launchable)"
}

Write-Output "Visual Studio 2019 = $msvc2019Version" >> ~\versions.txt
Write-Output "Visual Studio 2019 Build Tools = $version" >> ~\versions.txt

# Add Windows SDK Version and VCTools Version to versions.txt
cmd /c '"C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat" amd64 & set' |Select-String -Pattern '(WindowsSDKVersion)|(VCToolsVersion)' >> ~\versions.txt
