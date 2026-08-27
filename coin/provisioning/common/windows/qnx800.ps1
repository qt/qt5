# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script installs QNX 8.

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
$folderName = "qnx800"
$targetPath = "$targetFolder$folderName"

# QNX SDP
$cachedUrl = "\\ci-files01-hki.ci.qt.io\provisioning\qnx\qnx800-windows-linux-20260828.tar.xz"
$sourceFile = "http://ci-files01-hki.ci.qt.io/input/qnx/qnx800-windows-linux-20260828.tar.xz"
$targetFile = "qnx800.tar.xz"
$sha1 = "f44b66d91625ab33e367cfb62a2950a041607caa"
DownloadAndExtract $sourceFile $sha1 $targetFile $targetFolder $cachedUrl

# IANA timezone database overlay. Packaged separately from the SDP so it can be
# bumped without rebuilding the SDP tarball. Archive root is qnx800/target/qnx/
# so it overlays onto $targetFolder (C:\Utils\) directly.
$cachedUrl = "\\ci-files01-hki.ci.qt.io\provisioning\qnx\zoneinfo-2026a.tar.xz"
$sourceFile = "http://ci-files01-hki.ci.qt.io/input/qnx/zoneinfo-2026a.tar.xz"
$targetFile = "zoneinfo.tar.xz"
$sha1 = "8c1678ff673bb588f63fc9277497cd38e0ea2253"
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
Set-EnvironmentVariable "QNX_800" "$targetPath"
Set-EnvironmentVariable "QNX_800_CMAKE" "C:/Utils/$folderName"

Write-Output "QNX SDP = 8.0.0" >> ~\versions.txt
