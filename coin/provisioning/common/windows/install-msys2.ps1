# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will installs msys2

$version = "20240113"
$prog = "msys2"
$arch = "x86_64"
$sha1 = "b46c08fd901da0fdba1dc30422a322766d7d03c6"
$sha1_prebuilt = "d86d45d72228f53f7ae060771bc95b6f54c703c8"
$folder = "msys64"

$package_prebuilt = $folder + "_" + $version + "_prebuilt.7z"
$package = $prog + "-base-" + $arch + "-" + $version + ".tar.xz"

$url_cache_prebuilt = "\\ci-files01-hki.ci.qt.io\provisioning\windows\$package_prebuilt"
$url_cache = "https://ci-files01-hki.ci.qt.io/input/windows/$package"
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

    # install perl make and yasm
    # Run these without 'Run-Executable' function. When using the function the gpg-agent will lock the needed tmp*.tmp file.
    cmd /c "$msys `"-l`" `"-c`" `"rm -rf /etc/pacman.d/gnupg;pacman-key --init;pacman-key --populate msys2;pacman-key --refresh;pacman -S --noconfirm perl make yasm diffutils`""
    Start-Sleep -s 60
    cmd /c "$msys `"-l`" `"-c`" `"echo y | cpan -i Text::Template Test::More`""

    # Sometimes gpg-agent won't get killed after the installation process. If that happens the provisioning will won't continue and it will hang until timeout. So we need make sure it will be killed.
    # Let's sleep for awhile and wait that msys installation is finished. Otherwise the installation might start up gpg-agent or dirmngr after the script has passed the killing process.
    Start-Sleep -s 360
    if (Get-Process -Name "gpg-agent" -ErrorAction SilentlyContinue) { Stop-Process -Force -Name gpg-agent }
    if (Get-Process -Name "dirmngr" -ErrorAction SilentlyContinue) { Stop-Process -Force -Name dirmngr }
}

Write-Host "Cleaning $PackagePath.."
Remove "$PackagePath"

Write-Output "msys2 = $version" >> ~\versions.txt
