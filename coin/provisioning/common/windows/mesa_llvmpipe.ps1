# Copyright (C) 2020 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
. "$PSScriptRoot\helpers.ps1"

$version = "11_2_2"
$package = "C:\Windows\temp\opengl32sw.7z"
$mesaOpenglSha1_64 = "58f948746696b17a594b2f542e87b0e831b28dc3"
$mesaOpenglUrl_64_cache = "http://ci-files01-hki.ci.qt.io/input/windows/opengl32sw-64-mesa_$version-signed_sha256.7z"
$mesaOpenglUrl_64_alt = "http://download.qt.io/development_releases/prebuilt/llvmpipe/windows/opengl32sw-64-mesa_$version-signed_sha256.7z"
$mesaOpenglSha1_32 = "974f468acaa0018d46607e2100f1214fecd35bd4"
$mesaOpenglUrl_32_cache = "http://ci-files01-hki.ci.qt.io/input/windows/opengl32sw-32-mesa_$version-signed_sha256.7z"
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
