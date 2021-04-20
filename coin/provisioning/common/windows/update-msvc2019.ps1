############################################################################
##
## Copyright (C) 2021 The Qt Company Ltd.
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

# This script will update MSVC 2019.
# NOTE! Visual Studio is pre-installed to tier 1 image so this script won't install the whole Visual Studio. See ../../../pre-provisioning/qtci-windows-10-x86_64/msvc2019.txt
# MSVC 2019 online installers can be found from here https://docs.microsoft.com/en-us/visualstudio/releases/2019/history#installing-an-earlier-release

$version = "16_9_4"
$urlCache_vsInstaller = "\\ci-files01-hki.intra.qt.io\provisioning\windows\msvc\vs2019_Professional_$version.exe"
$urlOfficial_vsInstaller = "https://download.visualstudio.microsoft.com/download/pr/3105fcfe-e771-41d6-9a1c-fc971e7d03a7/d60c42571053950bf742db19e30430f76354c95af06afb1364d5b2aab620f4e5/vs_Professional.exe"
$sha1_vsInstaller = "03e3896b790b1734434ab12c2e06ca458e67395f"
$urlCache_buildToolsInstaller = "\\ci-files01-hki.intra.qt.io\provisioning\windows\msvc\vs2019_BuildTools_$version.exe"
$urlOfficial_buildToolsInstaller = "https://download.visualstudio.microsoft.com/download/pr/3105fcfe-e771-41d6-9a1c-fc971e7d03a7/e0c2f5b63918562fd959049e12dffe64bf46ec2e89f7cadde3214921777ce5c2/vs_BuildTools.exe"
$sha1_buildToolsInstaller = "59e62e552305e60420154395d79d5261d65f52dc"
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
    Run-Executable "$installerPath" "update --passive --wait"
    Remove-Item -Force -Path $installerPath
}

Install $urlOfficial_vsInstaller $urlCache_vsInstaller $sha1_vsInstaller
Install $urlOfficial_buildToolsInstaller $urlCache_buildToolsInstaller $sha1_buildToolsInstaller

$msvc2019Version = (cmd /c "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property catalog_productDisplayVersion 2`>`&1)

Write-Output "Visual Studio 2019 = $msvc2019Version" >> ~\versions.txt
Write-Output "Visual Studio 2019 Build Tools = $version" >> ~\versions.txt
