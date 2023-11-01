# Copyright (C) 2024 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\..\common\windows\helpers.ps1"

# This script installs LLVM-Mingw by mstorsjo
# https://github.com/mstorsjo/llvm-mingw/releases/tag/20240320

$zip = Get-DownloadLocation "llvm-mingw-20240320-ucrt-aarch64.zip"
$url_cache = "http://ci-files01-hki.ci.qt.io/input/windows/llvm-mingw-20240320-ucrt-aarch64.zip"
$url_official = "https://github.com/mstorsjo/llvm-mingw/releases/download/20240320/llvm-mingw-20240320-ucrt-aarch64.zip"

Download $url_official $url_cache $zip
Verify-Checksum $zip "1ea4870551a6aaf0d51332be1ea10ce776ee3b42"
Extract-7Zip $zip C:\

Rename-Item C:\llvm-mingw-20240320-ucrt-aarch64 C:\llvm-mingw

Write-Output "llvm-mingw = 18.1.2" >> ~/versions.txt
Remove-Item -Path $zip
