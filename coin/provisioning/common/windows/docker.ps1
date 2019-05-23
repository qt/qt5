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

# This script installs Docker tool kits and Apple Bonjour on Windows.

function DownloadAndInstall
{
    Param (
        [string]$externalUrl,
        [string]$internalUrl,
        [string]$package,
        [string]$sha1,
        [string]$parameters
    )

    Write-Host "Fetching $package from URL..."
    Download $externalUrl $internalUrl $package
    Verify-Checksum $package $sha1

    Write-Host "Installing $package..."
    Run-Executable $package $parameters

    Write-Host "Remove $package..."
    Remove-Item -Path $package
}

# Install Docker Toolbox
$package = Get-DownloadLocation "DockerToolbox.exe"
$externalUrl = "https://download.docker.com/win/stable/DockerToolbox.exe"
$internalUrl = "http://ci-files01-hki.intra.qt.io/input/windows/DockerToolbox.exe"
$sha1 = "62325c426ff321d9ebfb89664d65cf9ffaef2985"
DownloadAndInstall $externalUrl $internalUrl $package $sha1 "/SP- /SILENT"
Add-Path 'C:\Program Files\Docker Toolbox'
docker --version
docker-compose --version

# Install Apple Bonjour
$package = Get-DownloadLocation "BonjourPSSetup.exe"
$externalUrl = "http://support.apple.com/downloads/DL999/en_US/BonjourPSSetup.exe"
$internalUrl = "http://ci-files01-hki.intra.qt.io/input/windows/BonjourPSSetup.exe"
$sha1 = "847f39e0ea80d2a4d902fe59657e18f5bc32a8cb"
DownloadAndInstall $externalUrl $internalUrl $package $sha1 "/qr"

# Nested virtualization - Print CPU features to verify that CI has enabled VT-X/AMD-v support
$testserver = "$PSScriptRoot\..\shared\testserver\docker_testserver.sh"
$sysInfoStr = systeminfo
if ($sysInfoStr -like "*A hypervisor has been detected*") {
    & 'C:\Program Files\Git\bin\bash.exe' --login $testserver Hyper-V
} elseif ($sysInfoStr -like "*Virtualization Enabled In Firmware: Yes*") {
    & 'C:\Program Files\Git\bin\bash.exe' --login $testserver VMX
} else {
    Write-Error "VMX not found error! Please make sure Coin has enabled VT-X/AMD-v."
}
