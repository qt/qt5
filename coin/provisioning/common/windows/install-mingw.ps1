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
############################################################################

. "$PSScriptRoot\helpers.ps1"

function InstallMinGW
{
    Param (
        [string] $release = $(BadParam("release file name")),
        [string] $sha1    = $(BadParam("SHA1 checksum of the file"))
    )

    $null, $null, $arch, $version, $null, $threading, $ex_handling, $build_ver, $revision = $release.split('-')

    if ($arch -eq "x86_64") { $win_arch = "Win64" }
    $envvar = "MINGW$version"
    $envvar = $envvar -replace '["."]'
    $targetdir = "C:\$envvar"

    $url_original = "https://github.com/cristianadam/mingw-builds/releases/download/v" + $version + "-" + $revision + "/" + $arch + "-" + $version + "-release-" + $threading + "-" + $ex_handling + "-" + $build_ver + "-" + $revision + ".7z"
    $url_cache = "\\ci-files01-hki.intra.qt.io\provisioning\windows\" + $release + ".7z"
    $mingwPackage = "C:\Windows\Temp\MinGW-$version.zip"
    Download $url_original $url_cache $mingwPackage
    Verify-Checksum $mingwPackage $sha1

    Extract-7Zip $mingwPackage $TARGETDIR

    Set-EnvironmentVariable "$envvar" ("$targetdir\mingw" + $win_arch.Substring($win_arch.get_Length()-2))

    Write-Host "Cleaning $mingwPackage.."
    Remove "$mingwPackage"

    Write-Output "MinGW = $version $release" >> ~\versions.txt

}
