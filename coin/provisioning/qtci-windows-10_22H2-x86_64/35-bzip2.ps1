############################################################################
##
## Copyright (C) 2022 The Qt Company Ltd.
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

# This script will install prebuilt PZIB2 for IFW

# Prebuilt instructions:
# Download https://www.sourceware.org/pub/bzip2/bzip2-latest.tar.gz
#
# MSVC 2015 used with x86
# x86: Extract sources to C:\Utils
# x86: cd C:\Utils\bzip2-$version
# x86: start powershell
# x86: (Get-Content C:\Utils\bzip2-$version\makefile.msc) | ForEach-Object { $_ -replace "-DWIN32 -MD -Ox -D_FILE_OFFSET_BITS=64 -nologo", "-DWIN32 -MT -Ox -D_FILE_OFFSET_BITS=64 -nologo" } | Set-Content C:\Utils\bzip2-$version\makefile.msc
# x86: exit powershell
# x86: "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86
# x86: nmake -f makefile.msc
#
# MSVC 2019 used with x64
# x64: Extract sources to C:\Utils
# x64: rename source folder to C:\Utils\bzip2-$version-x64
# x64: start powershell
# x64: (Get-Content C:\Utils\bzip2-$version-x64\makefile.msc) | ForEach-Object { $_ -replace "-DWIN32 -MD -Ox -D_FILE_OFFSET_BITS=64 -nologo", "-DWIN32 -MT -Ox -D_FILE_OFFSET_BITS=64 -nologo" } | Set-Content C:\Utils\bzip2-$version-x64\makefile.msc
# x64: exit powershell
# x64: "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat" x64
# x64: nmake -f makefile.msc


$version = "1.0.8"
# Install x86 version
$sha1 = "4397208f4c4348d6662c9aa459cb3e508a872d42"
Download http://ci-files01-hki.intra.qt.io/input/windows/bzip2-$version-prebuilt.zip http://ci-files01-hki.intra.qt.io/input/windows/bzip2-$version-prebuilt.zip C:\Windows\Temp\bzip2-$version.zip
Verify-Checksum "C:\Windows\Temp\bzip2-$version.zip" "$sha1"
Extract-7Zip "C:\Windows\Temp\bzip2-$version.zip" C:\Utils
Remove-Item -Path "C:\Windows\Temp\bzip2-$version.zip"

#Install x64 version
$sha1_64 = "e4416598c8ba0aa1725a2bfab5a86f2ccd5effc3"
Download http://ci-files01-hki.intra.qt.io/input/windows/bzip2-$version-x64-prebuilt-msvc2019.zip http://ci-files01-hki.intra.qt.io/input/windows/bzip2-$version-x64-prebuilt-msvc2019.zip C:\Windows\Temp\bzip2-$version-x64-prebuilt-msvc2019.zip
Verify-Checksum "C:\Windows\Temp\bzip2-$version-x64-prebuilt-msvc2019.zip" "$sha1_64"
Extract-7Zip "C:\Windows\Temp\bzip2-$version-x64-prebuilt-msvc2019.zip" C:\Utils
Remove-Item -Path "C:\Windows\Temp\bzip2-$version-x64-prebuilt-msvc2019.zip"
Set-EnvironmentVariable "BZIP2" "C:\Utils\bzip2-$version-x64"

Write-Output "Bzip2 = $version" >> ~\versions.txt
