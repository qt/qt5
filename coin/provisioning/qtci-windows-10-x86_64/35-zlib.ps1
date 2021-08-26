############################################################################
##
## Copyright (C) 2021 The Qt Company Ltd.
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
############################################################################

. "$PSScriptRoot\..\common\windows\helpers.ps1"

# This script will install prebuilt ZLIB for IFW

# Prebuilt instructions:
# Download https://zlib.net/zlib1211.zip
# Extract to C:\Utils
# cd C:\Utils\zlib-$version
# (Get-Content C:\Utils\zlib-$version\win32\makefile.msc) | ForEach-Object { $_ -replace "-MD -W3 -O2 -Oy- -Zi", "-MT -W3 -O2 -Oy- -Zi" } | Set-Content C:\Utils\zlib-$version\win32\makefile.msc
# "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86
# nmake -f win32\makefile.msc

$version = "1.2.11"
$sha1 = "e1992ff9ad58ad6631a84c1557e2a158ec90c5ce"
Download http://ci-files01-hki.intra.qt.io/input/windows/zlib-$version-prebuilt.zip http://ci-files01-hki.intra.qt.io/input/windows/zlib-$version-prebuilt.zip C:\Windows\Temp\zlib-$version.zip
Verify-Checksum "C:\Windows\Temp\zlib-$version.zip" "$sha1"
Extract-7Zip "C:\Windows\Temp\zlib-$version.zip" C:\Utils
Remove-Item -Path "C:\Windows\Temp\zlib-$version.zip"

Write-Output "ZLIB = $version" >> ~\versions.txt

