# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

function DownloadAndInstallUA
{
    Param (
        [string] $InstallerFileName = $(BadParam("no download URL specified")),
        [string] $sha1 = $(BadParam("No SHA1 for download specified")),
        [string] $Destination = $(BadParam("No location to install specified"))
    )
    Write-Host "UACPPSDK: DownloadAndInstallUA $InstallerFileName"
    $zip = Get-DownloadLocation "uasdkcpp.zip"

    Write-Host "UACPPSDK: Downloading Unified Automation CPP installer..."
    $internalUrl = "http://ci-files01-hki.ci.qt.io/input/opcua_uacpp/$InstallerFileName.zip"
    # No public download link exists
    $externalUrl = $internalUrl

    Download $externalUrl $internalUrl $zip
    Verify-Checksum $zip $sha1

    Write-Host "UACPPSDK: Extracting $zip..."
    Extract-7Zip $zip (Get-DefaultDownloadLocation)
    Remove "$zip"

    $executable = (Get-DefaultDownloadLocation) + "$InstallerFileName.exe"
    # We cannot call the installer as the x86 and x64 versions of the installer are not
    # allowed to be installed in parallel (they check for the same registry value and
    # delete each other). Extracting does not have a side-effect for Qt
    #$arguments = "/S /D=$installLocation"
    #Run-Executable $executable $arguments
    #Write-Host "UACPPSDK: Installer done."
    #Remove-Item $executable

    Extract-7Zip $executable $Destination
    Remove "$executable"
}

#x86 version
$installerName86 = "uasdkcppbundle-bin-EVAL-win32-x86-vs2015-v1.6.3-406"
$downloadSha86 = "C73278B4C10DF0E3D60ABAA159ABA9185095124C"
$installLocation86 = "C:\Utils\uacpp_x86"

DownloadAndInstallUA $installerName86 $downloadSha86 $installLocation86
Set-EnvironmentVariable "CI_UACPP_msvc2015_x86_PREFIX" "$installLocation86"
# For UA msvc2015 is binary compatible with msvc2017
Set-EnvironmentVariable "CI_UACPP_msvc2017_x86_PREFIX" "$installLocation86"


#x64 version
$installerName64 = "uasdkcppbundle-bin-EVAL-win64-x86_64-vs2015-v1.6.3-406"
$downloadSha64 = "1384e6882644f9163e9840aee962cdb9ca3398c8"
$installLocation64 = "C:\Utils\uacpp_x64"

DownloadAndInstallUA $installerName64 $downloadSha64 $installLocation64
Set-EnvironmentVariable "CI_UACPP_msvc2015_x64_PREFIX" "$installLocation64"
# For UA msvc2015 is binary compatible with msvc2017
Set-EnvironmentVariable "CI_UACPP_msvc2017_x64_PREFIX" "$installLocation64"
