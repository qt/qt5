#############################################################################
##
## Copyright (C) 2020 The Qt Company Ltd.
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

$version = "11_2_2"
$package = "C:\Windows\temp\opengl32sw.7z"
$mesaOpenglSha1_64 = "58f948746696b17a594b2f542e87b0e831b28dc3"
$mesaOpenglUrl_64_cache = "http://ci-files01-hki.intra.qt.io/input/windows/opengl32sw-64-mesa_$version-signed_sha256.7z"
$mesaOpenglUrl_64_alt = "http://download.qt.io/development_releases/prebuilt/llvmpipe/windows/opengl32sw-64-mesa_$version-signed_sha256.7z"
$mesaOpenglSha1_32 = "974f468acaa0018d46607e2100f1214fecd35bd4"
$mesaOpenglUrl_32_cache = "http://ci-files01-hki.intra.qt.io/input/windows/opengl32sw-32-mesa_$version-signed_sha256.7z"
$mesaOpenglUrl_32_alt = "http://download.qt.io/development_releases/prebuilt/llvmpipe/windows/opengl32sw-32-mesa_$version-signed_sha256.7z"

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
    Remove "$package"
}

if (Is64BitWinHost) {
    Extract-Mesa $mesaOpenglUrl_64_cache $mesaOpenglUrl_64_alt $mesaOpenglSha1_64 "C:\Windows\System32"
    Extract-Mesa $mesaOpenglUrl_32_cache $mesaOpenglUrl_32_alt $mesaOpenglSha1_32 "C:\Windows\SysWOW64"
} else {
    Extract-Mesa $mesaOpenglUrl_32_cache $mesaOpenglUrl_32_alt $mesaOpenglSha1_32 "C:\Windows\system32"
}

Write-Output "Mesa llvmpipe = $version" >> ~/versions.txt
