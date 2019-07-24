############################################################################
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
$bash = "$TargetLocation\$folder\usr\bin\bash"

# install perl
Run-Executable "$bash" "`"-l`" `"-c`" `"rm -rf /etc/pacman.d/gnupg;pacman-key --init;pacman-key --populate msys2;pacman -S --noconfirm perl make`""
Run-Executable "$bash" "`"-l`" `"-c`" `"yes | cpan -i Text::Template Test::More`""

Write-Host "Cleaning $PackagePath.."
Remove-Item -Recurse -Force -Path "$PackagePath"

# pacman-key launches gpg-agent and dirmngr in the background, see https://github.com/Alexpux/MSYS2-pacman/issues/56
Stop-Process -Name "gpg-agent" -ErrorAction Ignore
Stop-Process -Name "dirmngr" -ErrorAction Ignore

Write-Output "MSYS2 = $version" >> ~\versions.txt
