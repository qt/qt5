#############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
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
. "$PSScriptRoot\..\common\helpers.ps1"

$version = "11_2_2"
$package = "C:\Windows\temp\opengl32sw.7z"
$mesaOpenglSha1_64 = "b2ffa5f230a0caa2c2e0bb9a5398bcfb81a0e5d1"
$mesaOpenglUrl_64 = "http://download.qt.io/development_releases/prebuilt/llvmpipe/windows/opengl32sw-64-mesa_$version.7z"
$mesaOpenglSha1_32 = "e742e9d4e16b9c69b6d844940861d3ef1748356b"
$mesaOpenglUrl_32 = "http://download.qt.io/development_releases/prebuilt/llvmpipe/windows/opengl32sw-32-mesa_$version.7z"

function Extract-Mesa
{
    Param (
        [string]$downloadUrl,
        [string]$sha1,
        [string]$targetFolder
    )
    Write-Host "Installing Mesa from $downloadUrl to $targetFolder"
    $localArchivePath = "C:\Windows\temp\opengl32sw.7z"
    Invoke-WebRequest -UseBasicParsing $downloadUrl -OutFile $localArchivePath
    Verify-Checksum $localArchivePath $sha1
    Get-ChildItem $package | % {& "C:\Utils\sevenzip\7z.exe" "x" "-y" $_.fullname "-o$targetFolder"}
    Remove-Item $localArchivePath
}

if ( Test-Path C:\Windows\SysWOW64 ) {
    Extract-Mesa $mesaOpenglUrl_64 $mesaOpenglSha1_64 "C:\Windows\sysnative"
    Extract-Mesa $mesaOpenglUrl_32 $mesaOpenglSha1_32 "C:\Windows\SysWOW64"
} else {
    Extract-Mesa $mesaOpenglUrl_32 $mesaOpenglSha1_32 "C:\Windows\system32"
}

