############################################################################
##
## Copyright (C) 2020 The Qt Company Ltd.
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

# This script will installs msys2

$version = "20200903"
$prog = "msys2"
$arch = "x86_64"
$sha1 = "5a1644585fac2d58855d48b4ba4a92579a14cf03"
$sha1_prebuilt = "d86d45d72228f53f7ae060771bc95b6f54c703c8"
$folder = "msys64"

$package_prebuilt = $folder + "_" + $version + "_prebuilt.7z"
$package = $prog + "-base-" + $arch + "-" + $version + ".tar.xz"

$url_cache_prebuilt = "\\ci-files01-hki.intra.qt.io\provisioning\windows\$package_prebuilt"
$url_cache = "\\ci-files01-hki.intra.qt.io\provisioning\windows\$package"
$url_official = "http://repo.msys2.org/distrib/$arch/$package"
$TargetLocation = "C:\Utils"


if ((Test-Path $url_cache_prebuilt)) {
    $PackagePath = "C:\Windows\Temp\$package_prebuilt"
    Download $url_cache_prebuilt $url_cache_prebuilt $PackagePath
    Verify-Checksum $PackagePath $sha1_prebuilt
    Extract-7Zip $PackagePath $TargetLocation
} else {
    $PackagePath = "C:\Windows\Temp\$package"
    Download $url_official $url_cache $PackagePath
    Verify-Checksum $PackagePath $sha1
    Extract-tar_gz $PackagePath $TargetLocation
    $msys = "$TargetLocation\$folder\msys2_shell.cmd"

    # install perl
    # Run these without 'Run-Executable' function. When using the function the gpg-agent will lock the needed tmp*.tmp file.
    cmd /c "$msys `"-l`" `"-c`" `"rm -rf /etc/pacman.d/gnupg;pacman-key --init;pacman-key --populate msys2;pacman -S --noconfirm perl make`""
    Start-Sleep -s 60
    cmd /c "$msys `"-l`" `"-c`" `"echo y | cpan -i Text::Template Test::More`""

    # Sometimes gpg-agent won't get killed after the installation process. If that happens the provisioning will won't continue and it will hang until timeout. So we need make sure it will be killed.
    # Let's sleep for awhile and wait that msys installation is finished. Otherwise the installation might start up gpg-agent or dirmngr after the script has passed the killing process.
    Start-Sleep -s 360
    if (Get-Process -Name "gpg-agent" -ErrorAction SilentlyContinue) { Stop-Process -Force -Name gpg-agent }
    if (Get-Process -Name "dirmngr" -ErrorAction SilentlyContinue) { Stop-Process -Force -Name dirmngr }
}

Write-Host "Cleaning $PackagePath.."
Remove-Item -Recurse -Force -Path "$PackagePath"

Write-Output "msys2 = $version" >> ~\versions.txt
