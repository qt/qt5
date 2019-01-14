#############################################################################
##
## Copyright (C) 2019 The Qt Company Ltd.
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
    $internalUrl = "http://ci-files01-hki.intra.qt.io/input/opcua_uacpp/$InstallerFileName.zip"
    # No public download link exists
    $externalUrl = $internalUrl

    Download $externalUrl $internalUrl $zip
    Verify-Checksum $zip $sha1

    Write-Host "UACPPSDK: Extracting $zip..."
    Extract-7Zip $zip (Get-DefaultDownloadLocation)
    Remove-Item -Path $zip

    $executable = (Get-DefaultDownloadLocation) + "$InstallerFileName.exe"
    # We cannot call the installer as the x86 and x64 versions of the installer are not
    # allowed to be installed in parallel (they check for the same registry value and
    # delete each other). Extracting does not have a side-effect for Qt
    #$arguments = "/S /D=$installLocation"
    #Run-Executable $executable $arguments
    #Write-Host "UACPPSDK: Installer done."
    #Remove-Item $executable

    Extract-7Zip $executable $Destination
    Remove-Item $executable
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
