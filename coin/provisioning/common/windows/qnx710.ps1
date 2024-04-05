# Copyright (C) 2021 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs QNX 7.

. "$PSScriptRoot\helpers.ps1"

$tempFolder = "c:\Windows\Temp"

function DownloadAndExtract($1, $2, $3, $4, $5) {
    $url = $1
    $sha = $2
    $file = $3
    $folder = $4
    $cachedUrl = $5

    Download $url $cachedUrl "$tempFolder\$file"
    Verify-Checksum "$tempFolder\$file" "$sha"
    Extract-tar_gz "$tempFolder\$file" $folder
}

$aarch64le_toolchain = "$PSScriptRoot\..\shared\cmake_toolchain_files\qnx-toolchain-aarch64le.cmake"
$armv7le_toolchain = "$PSScriptRoot\..\shared\cmake_toolchain_files\qnx-toolchain-armv7le.cmake"
$x8664_toolchain = "$PSScriptRoot\..\shared\cmake_toolchain_files\qnx-toolchain-x8664.cmake"

$targetFolder = "C:\Utils\"
$folderName = "qnx710"
$targetPath = "$targetFolder$folderName"

# QNX SDP
$cachedUrl = "\\ci-files01-hki.ci.qt.io\provisioning\qnx\qnx710-windows-linux-20240417.tar.xz"
$sourceFile = "http://ci-files01-hki.ci.qt.io/input/qnx/qnx710-windows-linux-20240417.tar.xz"
$targetFile = "qnx710.tar.xz"
$sha1 = "cd2d35004fb2798089e29d9e1226691426632da0"
DownloadAndExtract $sourceFile $sha1 $targetFile $targetFolder $cachedUrl

Copy-Item $aarch64le_toolchain $targetPath
Copy-Item $armv7le_toolchain $targetPath
Copy-Item $x8664_toolchain $targetPath

cmd /c "dir $targetPath"

# Verify that we have last files in tars
if (-not (test-path $targetPath\qnxsdp-env.bat)) {
    throw "QNX SDP installation failed!"
}
if (-not (test-path $targetPath\qnx-toolchain-x8664.cmake)) {
    throw "QNX toolchain installation failed!"
}

# Set env variables
Set-EnvironmentVariable "QNX_710" "$targetPath"
Set-EnvironmentVariable "QNX_710_CMAKE" "C:/Utils/$folderName"

Write-Output "QNX SDP = 7.1.0" >> ~\versions.txt

