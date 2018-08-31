#############################################################################
##
## Copyright (C) 2018 The Qt Company Ltd.
## Contact: http://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL21$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see http://www.qt.io/terms-conditions. For further
## information use the contact form at http://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 2.1 or version 3 as published by the Free
## Software Foundation and appearing in the file LICENSE.LGPLv21 and
## LICENSE.LGPLv3 included in the packaging of this file. Please review the
## following information to ensure the GNU Lesser General Public License
## requirements will be met: https://www.gnu.org/licenses/lgpl.html and
## http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
##
## As a special exception, The Qt Company gives you certain additional
## rights. These rights are described in The Qt Company LGPL Exception
## version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
##
## $QT_END_LICENSE$
##
#############################################################################

Param (
    [string]$targetCommand= ""
    )

. "$PSScriptRoot\helpers.ps1"

## Variables for builds
$commitSHA = "215651ab8db94e5eacdd10ec26a5a9fb96b9301f"
$sha1 = "8d899f986071525be73e1ee8565b28ea10536d7d"
$extractTarget = "C:\open62541_build"

function CreateArchive
{
    param(
        [string]$sourceDirectory=$(throw("You must specify a directory")),
        [string]$archiveName=$(throw("You must specify an archive name"))
    )

    if ((Get-Command "7z.exe" -ErrorAction SilentlyContinue) -eq $null) {
        $zipExe = join-path (${env:ProgramFiles(x86)}, ${env:ProgramFiles}, ${env:ProgramW6432} -ne $null)[0] '7-zip\7z.exe'
        if (-not (test-path $zipExe)) {
            $zipExe = "C:\Utils\sevenzip\7z.exe"
            if (-not (test-path $zipExe)) {
                throw "Could not find 7-zip."
            }
        }
    } else {
        $zipExe = "7z.exe"
    }

    Run-Executable $zipExe "a -y `"$archiveName`" `"$sourceDirectory`""
}

function PrepareRepository
{
    $username = $env:USERNAME
    $zip = "c:\users\$username\downloads\open62541.zip"

    $externalUrl = "https://github.com/open62541/open62541/archive/$commitSHA.zip"
    $internalUrl = "http://ci-files01-hki.ci.local/input/open62541/$commitSHA.zip"

    Download $externalUrl $internalUrl $zip
    Verify-Checksum $zip $sha1

    Extract-7Zip $zip $extractTarget
}

function PushDevEnvironment
{
    # Provisioning updates the registry entries for PATH etc. However, they are not
    # propagated to the next provisioning script and hence need to be manually
    # read / set.
    $adaptedPath = $env:PATH
    $jomLocation = [Environment]::GetEnvironmentVariable("CI_JOM_PATH", "Machine")
    $adaptedPath = $adaptedPath + ";" + $jomLocation
    $adaptedPath = $adaptedPath + ";" + "C:\Python27"
    $adaptedPath = $adaptedPath + ";" + "C:\CMake\bin"
    [Environment]::SetEnvironmentVariable("PATH", $adaptedPath, "Process")
}

function MSVCEnvironment
{
    Param (
        [string]$msvcDir=$(throw("No VS Directory specified")),
        [string]$msvcbat=$(throw("No vsvars batch file specified"))
    )

    Push-Location $msvcDir
    cmd /c "$msvcbat&set" |
    foreach {
        if ($_ -match "=") {
            $v = $_.split("="); Set-Item -force -path "ENV:\$($v[0])" -value "$($v[1])"
        }
    }
    Pop-Location
}

function BuildAndInstallOpen62541
{
    Param (
        [string]$Type=$(throw("You must specify the dev type [mingw530, mingw630, mingw730, msvc2015, msvc2017]")),
        [string]$Platform=$(throw("You must specify the target platform [x86, x64]")),
        [string]$MakeCommand=$(throw("You must specify a make command [mingw32-make, nmake]"))
    )
    Write-Host "### Open62541: Supposed to build with: $Type $Platform $MakeCommand"

    ## Make Build directory
    $buildDir = "$extractTarget\open62541-$commitSHA\build" + "_" + $Type + "_" + $Platform
    if (Test-Path $buildDir) {
        Write-Host " Deleting pre-existing build directory"
        Remove-Item $buildDir -Force -Recurse
    }
    New-Item -ItemType Directory -Force -Path $buildDir
    Push-Location $buildDir

    ## Invoke Cmake
    $makeGenerator = "NMake Makefiles JOM"
    $installTarget = "C:\Utils\open62541" + "_" + $Type + "_" + $Platform
    if (Test-Path $installTarget) {
        Write-Host " Deleting pre-existing install directory"
        Remove-Item $installTarget -Force -Recurse
    }

    if ($Type.StartsWith("mingw")) {
        $makeGenerator = "MinGW Makefiles"
    }
    cmake -G "$makeGenerator" -DUA_ENABLE_AMALGAMATION=ON -DUA_ENABLE_METHODCALLS=ON -DCMAKE_INSTALL_PREFIX:PATH=$installTarget -DLIB_INSTALL_DIR:PATH=$installTarget/lib ..

    ## Call build command
    Write-Host "### Open62541: Compilation ###"
    Run-Executable $MakeCommand

    ## call install command
    Write-Host "### Open62541: Installation ###"
    Run-Executable $MakeCommand install

    $platformVariable = "CI_OPEN62541_" + $Type + "_" + $Platform + "_PREFIX"
    Set-EnvironmentVariable $platformVariable $installTarget

    ## Packaging
    Push-Location "C:\Utils"
    $archiveName = "open62541_" + $Type + "_" + $Platform + ".7z"
    CreateArchive $installTarget $archiveName
    Pop-Location

    ## cleanup build directory
    Write-Host "### Open62541: Cleanup ###"
    Pop-Location
    Remove-Item $buildDir -Force -Recurse
}

function DownloadAndInstall
{
    Param (
        [string]$Type=$(throw("You must specify the dev type [mingw530, mingw630, mingw730, msvc2015, msvc2017]")),
        [string]$Platform=$(throw("You must specify the target platform [x86, x64]"))
    )
    $baseLocation = "http://ci-files01-hki.intra.qt.io/input/open62541/"
    $targetName = "open62541_" + $Type + "_" + $Platform
    $archiveName =  $targetName + ".7z"
    $downloadUrl = $baseLocation + $archiveName

    # Download
    $downloadTarget = "C:\Utils\" + $archiveName
    Download $downloadUrl $downloadUrl $downloadTarget

    # Extract
    Push-Location C:\Utils
    Extract-7Zip $downloadTarget C:\Utils
    Pop-Location

    # Set environment variable
    $platformVariable = "CI_OPEN62541_" + $Type + "_" + $Platform
    $platformPath = "C:\Utils\" + $targetName
    Set-EnvironmentVariable $platformVariable $platformPath
}

##############################
# Startup                    #
##############################
if ($targetCommand.StartsWith("mingw")) {
    Write-Host "### Creating Open62541 for MinGW"
    $mingwPath = [Environment]::GetEnvironmentVariable($targetCommand, "Machine")
    if (!$mingwPath) {
        throw("Could not find mingw")
    }

    # Strawberry has its own gcc, put mingw in front
    $adaptedPath = $mingwPath + "\bin;" + [Environment]::GetEnvironmentVariable("PATH", "Machine")
    [Environment]::SetEnvironmentVariable("PATH", $adaptedPath, "Process")

    PushDevEnvironment
    BuildAndInstallOpen62541 $targetCommand x86 "mingw32-make"
} elseif ($targetCommand -eq "msvc2015_x86") {
    Write-Host "### Creating Open62541 for MSVC2015 x86"
    MSVCEnvironment "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC" "vcvarsall.bat x86"
    PushDevEnvironment
    BuildAndInstallOpen62541 msvc2015 x86 jom
} elseif ($targetCommand -eq "msvc2015_x64") {
    Write-Host "### Creating Open62541 for MSVC2015 x64"
    MSVCEnvironment "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC" "vcvarsall.bat amd64"
    PushDevEnvironment
    BuildAndInstallOpen62541 msvc2015 x64 jom
} elseif ($targetCommand -eq "msvc2017_x86") {
    Write-Host "### Creating Open62541 for MSVC2017 x86"
    MSVCEnvironment "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build" vcvars32.bat
    PushDevEnvironment
    BuildAndInstallOpen62541 msvc2017 x86 jom
} elseif ($targetCommand -eq "msvc2017_x64") {
    Write-Host "### Creating Open62541 for MSVC2017 x64"
    MSVCEnvironment "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build" vcvars64.bat
    PushDevEnvironment
    BuildAndInstallOpen62541 msvc2017 x64 jom
} elseif ($targetCommand -eq "prepare") {
    PrepareRepository
} elseif ($targetCommand -eq "build") {
    Write-Host "### Building for all supported platforms"
    PrepareRepository
    Write-Host "### Invoking MinGW530 build"
    PowerShell -ExecutionPolicy Bypass -File "$PSScriptRoot\open62541.ps1" -targetCommand mingw530
    Write-Host "### Invoking MinGW630 build"
    PowerShell -ExecutionPolicy Bypass -File "$PSScriptRoot\open62541.ps1" -targetCommand mingw630
    Write-Host "### Invoking MinGW730 build"
    PowerShell -ExecutionPolicy Bypass -File "$PSScriptRoot\open62541.ps1" -targetCommand mingw730
    Write-Host "### Invoking MSVC2015 build"
    PowerShell -ExecutionPolicy Bypass -File "$PSScriptRoot\open62541.ps1" -targetCommand msvc2015_x86
    PowerShell -ExecutionPolicy Bypass -File "$PSScriptRoot\open62541.ps1" -targetCommand msvc2015_x64
    Write-Host "### Invoking MSVC2017 build"
    PowerShell -ExecutionPolicy Bypass -File "$PSScriptRoot\open62541.ps1" -targetCommand msvc2017_x86
    PowerShell -ExecutionPolicy Bypass -File "$PSScriptRoot\open62541.ps1" -targetCommand msvc2017_x64
    Write-Host "### Archives have been generated at C:/Utils. Please upload manually"
} elseif ($targetCommand -eq "packaged") {
    Write-Host "### Expecting pre-built packages, download and install from archives"
    Write-Host "### MinGW530 x64"
    DownloadAndInstall mingw530 x86
    Write-Host "### MinGW630 x64"
    DownloadAndInstall mingw630 x86
    Write-Host "### MinGW730 x64"
    DownloadAndInstall mingw730 x64
    Write-Host "### MSVC2015 x86"
    DownloadAndInstall msvc2015 x86
    Write-Host "### MSVC2015 x64"
    DownloadAndInstall msvc2015 x64
    Write-Host "### MSVC2017 x64"
    DownloadAndInstall msvc2017 x64
} elseif ($targetCommand) {
    Write-Host "### Unknown parameter specified:" $targetCommand " Options are: mingw, msvc2015_x(86/64), msvc2017_x(86/64)"
    throw("Unknown parameter")
} else {
    # Default behavior
    PowerShell -ExecutionPolicy Bypass -File "$PSScriptRoot\open62541.ps1" -targetCommand build
}
