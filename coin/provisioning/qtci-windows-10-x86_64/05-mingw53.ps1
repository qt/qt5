#############################################################################
##
## Copyright (C) 2017 The Qt Company Ltd.
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

. "$PSScriptRoot\..\common\helpers.ps1"

# This script installs MinGW 5.3


$zip = "c:\users\qt\downloads\i686-5.3.0-release-posix-dwarf-rt_v4-rev0.7z"

Invoke-WebRequest -UseBasicParsing  http://download.qt.io/development_releases/prebuilt/mingw_32/i686-5.3.0-release-posix-dwarf-rt_v4-rev0.7z -OutFile $zip
Verify-Checksum $zip "d4f21d25f3454f8efdada50e5ad799a0a9e07c6a"
Extract-7Zip $zip C:\
Rename-Item -path C:\mingw32 -newName C:\MinGW530

[Environment]::SetEnvironmentVariable("MINGW530", "C:\MinGW530", "Machine")
echo "MinGW = 5.3.0" >> ~/versions.txt
del $zip
