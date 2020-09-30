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

. "$PSScriptRoot\..\common\windows\helpers.ps1"

# This script installs LLVM-Mingw by mstorsjo

$zip = Get-DownloadLocation "llvm-mingw-20201020-ucrt-x86_64.zip"
$url_cache = "http://ci-files01-hki.intra.qt.io/input/windows/llvm-mingw-20201020-ucrt-x86_64.zip"
$url_official = "https://github.com/mstorsjo/llvm-mingw/releases/download/20201020/llvm-mingw-20201020-ucrt-x86_64.zip"

Download $url_official $url_cache $zip
Verify-Checksum $zip "fdb40870de0967b5116855901196fc277087d76f"
Extract-7Zip $zip C:\

Write-Output "llvm-mingw = 20201020" >> ~/versions.txt
Remove-Item -Path $zip

# Apply patch https://reviews.llvm.org/D92379
$patch = Get-DownloadLocation "lgamma_fix_for_llvm-mingw.patch"
$url_cache = "http://ci-files01-hki.intra.qt.io/input/windows/lgamma_fix_for_llvm-mingw.patch"
Download $url_cache $url_cache $patch
Verify-Checksum $patch d0f5fb2a5168d409eaee66542954aa22ac3ed1d8

Run-Executable "C:\Program Files\Git\usr\bin\patch" "-u -b c:/llvm-mingw/include/c++/v1/random -i $patch"

# Get fixed llvm-rc.exe (fixes https://reviews.llvm.org/D92558)
$fix = Get-DownloadLocation "llvm-rc.exe"
$url_cache = "http://ci-files01-hki.intra.qt.io/input/windows/llvm-rc.exe"
Download $url_cache $url_cache $fix
Verify-Checksum $fix 75afa882bd587138481b632409c0a3fcb09ba75f

Rename-Item -Path "C:\llvm-mingw\bin\llvm-rc.exe" -NewName "llvm-rc.orig"
Copy-Item $fix -Destination "C:\llvm-mingw\bin\"


