# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\..\common\windows\helpers.ps1"

# This script installs LLVM-Mingw by mstorsjo
# https://github.com/mstorsjo/llvm-mingw/releases/tag/20220906

$zip = Get-DownloadLocation "llvm-mingw-20220906-ucrt-x86_64.zip"
$url_cache = "http://ci-files01-hki.ci.qt.io/input/windows/llvm-mingw-20220906-ucrt-x86_64.zip"
$url_official = "https://github.com/mstorsjo/llvm-mingw/releases/download/20220906/llvm-mingw-20220906-ucrt-x86_64.zip"

Download $url_official $url_cache $zip
Verify-Checksum $zip "51ff525eefa4f5db905cc7b4c8b56079c3baed65"
Extract-7Zip $zip C:\

Rename-Item C:\llvm-mingw-20220906-ucrt-x86_64 C:\llvm-mingw

Write-Output "llvm-mingw = 15.0.0" >> ~/versions.txt
Remove-Item -Path $zip
