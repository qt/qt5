############################################################################
##
## Copyright (C) 2022 The Qt Company Ltd.
## Contact: https://www.qt.io/licensing/
##
## This file is part of the provisioning scripts of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## Commercial License Usage
## Licensees holding valid commercial Qt licenses may use this file in
## accordance with the commercial license agreement provided with the
## Software or, alternatively, in accordance with the terms contained in
## a written agreement between you and The Qt Company. For licensing terms
## and conditions see https://www.qt.io/terms-conditions. For further
## information use the contact form at https://www.qt.io/contact-us.
##
## GNU Lesser General Public License Usage
## Alternatively, this file may be used under the terms of the GNU Lesser
## General Public License version 3 as published by the Free Software
## Foundation and appearing in the file LICENSE.LGPL3 included in the
## packaging of this file. Please review the following information to
## ensure the GNU Lesser General Public License version 3 requirements
## will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU
## General Public License version 2.0 or (at your option) the GNU General
## Public license version 3 or any later version approved by the KDE Free
## Qt Foundation. The licenses are as published by the Free Software
## Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
## included in the packaging of this file. Please review the following
## information to ensure the GNU General Public License requirements will
## be met: https://www.gnu.org/licenses/gpl-2.0.html and
## https://www.gnu.org/licenses/gpl-3.0.html.
##
## $QT_END_LICENSE$
##
#############################################################################

. "$PSScriptRoot\helpers.ps1"

# This script will install FFmpeg
$msys = "C:\Utils\msys64\usr\bin\bash"

$version = "n5.0"
$ffmpeg_name = "ffmpeg-" + $version;
$sha1 = "3F7C6D5264A04BC27BA471D189B0483954820D65"

$url_cached = "http://ci-files01-hki.intra.qt.io/input/ffmpeg/" + $version + ".zip"
$url_public = "https://github.com/FFmpeg/FFmpeg/archive/refs/tags/" +$version + ".zip"
$download_location = "C:\Windows\Temp\" + $ffmpeg_name + ".zip"
$unzip_location = "C:\"

Write-Host "Fetching FFmpeg $version..."

Download $url_public $url_cached $download_location
Verify-Checksum $download_location $sha1
Extract-7Zip $download_location $unzip_location
Remove $download_location

function CheckExitCode {
    param ($p)

    if ($p.ExitCode) {
        Write-host "Process failed with exit code: $($p.ExitCode)"
        exit 1
    }
}

$config = Get-Content "$PSScriptRoot\..\shared\ffmpeg_config_options.txt"
Write-Host "FFmpeg configuration $config"

Write-Host "Configure and compile ffmpeg for MINGW"
$mingw = [System.Environment]::GetEnvironmentVariable("MINGW1120", [System.EnvironmentVariableTarget]::Machine)
$env:PATH += ";$mingw\bin"
$env:MSYS2_PATH_TYPE = "inherit"
$env:MSYSTEM = "MINGW"

$cmd  = "cd /c/$ffmpeg_name"
$cmd += "&& mkdir -p build/mingw && cd build/mingw"
$cmd += "&& ../../configure --prefix=installed $config"
$cmd += "&& make install -j"

$build = Start-Process -NoNewWindow -Wait -PassThru -ErrorAction Stop -FilePath "$msys" -ArgumentList ("-lc", "`"$cmd`"")
CheckExitCode $build

Set-EnvironmentVariable "FFMPEG_DIR_MINGW" "C:\$ffmpeg_name\build\mingw\installed"


Write-Host "Enter VisualStudio developer shell"
$vsPath = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional"
try {
    Import-Module "$vsPath\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
    Enter-VsDevShell -VsInstallPath $vsPath -DevCmdArguments "-arch=x64 -no_logo"
} catch {
    Write-host "Failed to enter VisualStudio DevShell"
    exit 1
}

Write-Host "Configure and compile ffmpeg for MSVC"
$env:MSYSTEM = "MSYS"
$env:MSYS2_PATH_TYPE = "inherit"

$cmd  = "CC=cl;"
$cmd += "cd /c/$ffmpeg_name"
$cmd += "&& mkdir -p build/msvc && cd build/msvc"
$cmd += "&& ../../configure --toolchain=msvc --prefix=installed $config"
$cmd += "&& make install -j"

$build = Start-Process -NoNewWindow -Wait -PassThru -ErrorAction Stop -FilePath "$msys" -ArgumentList ("-lc", "`"$cmd`"")
CheckExitCode $build

$ffmpeg_mscv_install = "C:\$ffmpeg_name\build\msvc\installed"

# As ffmpeg build system creates lib*.a file we have to rename them to *.lib files to be recognized by WIN32
Write-Host "Rename libraries lib*.a -> *.lib"
Get-ChildItem "$ffmpeg_mscv_install\lib\lib*.a" | Rename-Item -NewName { $_.Name -replace 'lib(\w+).a$', '$1.lib' }

Set-EnvironmentVariable "FFMPEG_DIR_MSVC" $ffmpeg_mscv_install
