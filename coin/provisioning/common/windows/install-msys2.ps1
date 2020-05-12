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

# This script installs 7-Zip

$version = "20181211"
$prog = "msys2"
if (Is64BitWinHost) {
    $arch = "x86_64"
    $sha1 = "d689ff74fd060934bd7aaf458a11db67833463c2"
    $folder = "msys64"
} else {
    $arch = "i686"
    $sha1 = "928f9d1537d1a77dc7f2adab74fb438e7d11a98e"
    $folder = "msys32"
}
$package = $prog + "-base-" + $arch + "-" + $version + ".tar.xz"


$url_cache = "\\ci-files01-hki.intra.qt.io\provisioning\windows\$package"
$url_official = "http://repo.msys2.org/distrib/$arch/$package"
$PackagePath = "C:\Windows\Temp\$package"
$TargetLocation = "C:\Utils"


Download $url_official $url_cache $PackagePath
Verify-Checksum $PackagePath $sha1
Extract-tar_gz $PackagePath $TargetLocation
$msys = "$TargetLocation\$folder\msys2_shell.cmd"

# install perl
# Run these without 'Run-Executable' function. When using the function the gpg-agent will lock the needed tmp*.tmp file.
cmd /c "$msys `"-l`" `"-c`" `"rm -rf /etc/pacman.d/gnupg;pacman-key --init;pacman-key --populate msys2;pacman -S --noconfirm perl make`""
Start-Sleep -s 30
cmd /c "$msys `"-l`" `"-c`" `"cpan -i Text::Template Test::More`""

# Sometimes gpg-agent won't get killed after the installation process. If that happens the provisioning will won't continue and it will hang until timeout. So we need make sure it will be killed.
# Let's sleep for awhile and wait that msys installation is finished. Otherwise the installation might start up gpg-agent or dirmngr after the script has passed the killing process.
Start-Sleep -s 180
if (Get-Process -Name "gpg-agent" -ErrorAction SilentlyContinue) { Stop-Process -Force -Name gpg-agent }
if (Get-Process -Name "dirmngr" -ErrorAction SilentlyContinue) { Stop-Process -Force -Name dirmngr }

Write-Host "Cleaning $PackagePath.."
Remove-Item -Recurse -Force -Path "$PackagePath"

Write-Output "7-Zip = $version" >> ~\versions.txt
