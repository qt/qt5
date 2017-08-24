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

$version = "11_2_2"
$openglPackage = "C:\Windows\SysWOW64\opengl32.dll"

$openglUrl = "\\ci-files01-hki.intra.qt.io\provisioning\mesa3d\windows\32bit\opengl32.dll"
$openglSha1 = "690730f973aa39bd80648e026248394fde07a753"

echo "Take ownership of existing opengl32.dll from SysWOW64"
takeown /f $openglPackage
icacls $openglPackage /grant Administrators:F
echo "Remove existing opengl32.dll from SysWOW64"
Remove-Item -Recurse -Force $openglPackage
echo "Add new opengl32.dll to SysWOW64"
Invoke-WebRequest -UseBasicParsing $openglUrl -OutFile $openglPackage
Verify-Checksum $openglPackage $openglSha1

# Store version information to ~/versions.txt
echo "OpenGL x86 = $version" >> ~/versions.txt
