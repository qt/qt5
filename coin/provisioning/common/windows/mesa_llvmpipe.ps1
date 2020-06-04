#############################################################################
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

$version = "11_2_2"
$package = "C:\Windows\temp\opengl32sw.7z"
$mesaOpenglSha1_64 = "0ed35efbc8112282be5d0c87c37fde2d15e81998"
$mesaOpenglUrl_64_cache = "http://ci-files01-hki.intra.qt.io/input/windows/opengl32sw-64-mesa_$version-signed.7z"
$mesaOpenglUrl_64_alt = "http://download.qt.io/development_releases/prebuilt/llvmpipe/windows/opengl32sw-64-mesa_$version-signed.7z"
$mesaOpenglSha1_32 = "96bd6ca0d7fd249fb61531dca888965ffd20f53c"
$mesaOpenglUrl_32_cache = "http://ci-files01-hki.intra.qt.io/input/windows/opengl32sw-32-mesa_$version-signed.7z"
$mesaOpenglUrl_32_alt = "http://download.qt.io/development_releases/prebuilt/llvmpipe/windows/opengl32sw-32-mesa_$version-signed.7z"

function Extract-Mesa
{
    Param (
        [string]$downloadUrlCache,
        [string]$downloadUrlAlt,
        [string]$sha1,
        [string]$targetFolder
    )
    Download $downloadUrlAlt $downloadUrlCache $package
    Verify-Checksum $package $sha1
    Extract-7Zip $package $targetFolder
    Write-Host "Removing $package"
    Remove-Item -Path $package
}

if (Is64BitWinHost) {
    Extract-Mesa $mesaOpenglUrl_64_cache $mesaOpenglUrl_64_alt $mesaOpenglSha1_64 "C:\Windows\System32"
    Extract-Mesa $mesaOpenglUrl_32_cache $mesaOpenglUrl_32_alt $mesaOpenglSha1_32 "C:\Windows\SysWOW64"
} else {
    Extract-Mesa $mesaOpenglUrl_32_cache $mesaOpenglUrl_32_alt $mesaOpenglSha1_32 "C:\Windows\system32"
}

Write-Output "Mesa llvmpipe = $version" >> ~/versions.txt
