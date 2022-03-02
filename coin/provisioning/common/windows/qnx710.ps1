#############################################################################
##
## Copyright (C) 2021 The Qt Company Ltd.
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
$cachedUrl = "\\ci-files01-hki.intra.qt.io\provisioning\qnx\qnx710-windows-linux-20220405.tar.xz"
$sourceFile = "http://ci-files01-hki.ci.qt.io/input/qnx/qnx710-windows-linux-20220405.tar.xz"
$targetFile = "qnx710.tar.xz"
$sha1 = "134af2e0f75d7b7c516f824fafee265b89e51d48"
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

