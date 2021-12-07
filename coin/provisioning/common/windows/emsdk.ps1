############################################################################
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
############################################################################

. "$PSScriptRoot\helpers.ps1"

# This script will install emscripten needed by WebAssembly

$version = "3.0.0"
$versionNode = "14.15.5"
$versionWinPython = "3.9.2-1"
$versionJre = "8.152"

# Make sure python is in the path
Prepend-Path "C:\Python27"

cd "C:\\Utils"
C:\PROGRA~1\Git\bin\git clone https://github.com/emscripten-core/emsdk.git
$installLocationEmsdk = "C:\\Utils\\emsdk"
cd $installLocationEmsdk
.\emsdk install $version
.\emsdk activate $version

Set-EnvironmentVariable "EMSDK" "$installLocationEmsdk"
Set-EnvironmentVariable "EM_CONFIG" "$installLocationEmsdk\.emscripten"
Set-EnvironmentVariable "EMSDK_NODE" "$installLocationEmsdk\node\${versionNode}_64bit\bin\node.exe"
Set-EnvironmentVariable "EMSDK_PYTHON" "$installLocationEmsdk\python\${versionWinPython}_64bit\python.exe"
Set-EnvironmentVariable "EMSDK_JAVA_HOME" "$installLocationEmsdk\java\${versionJre}_64bit"
Set-EnvironmentVariable "EMSDK_PATH" "$installLocationEmsdk;$installLocationEmsdk\node\${versionNode}_64bit\bin;$installLocationEmsdk\upstream\emscripten;$PATH"
Add-Path "$env:EMSDK_PATH"

# These can be removed when installing emsdk using emsdk.git
Set-Content -Path C:\Utils\emsdk\emsdk_env.bat -Value ":: This file is needed to get support for setting Emscripten environment for Webassembly through qtbase" -Encoding ASCII
Set-Content -Path C:\Utils\emsdk\emsdk_env.bat -Value ":: This file will have environment variables when https://codereview.qt-project.org/c/qt/qt5/+/372122 get merged" -Encoding ASCII
Set-Content -Path C:\Utils\emsdk\emsdk_env.bat -Value "echo nothing to run at this point" -Encoding ASCII

Write-Output "emsdk = $version" >> ~/versions.txt
Write-Output "emsdk NodeJs = $versionNode" >> ~/versions.txt
Write-Output "emsdk WinPython 64bit = $versionWinPython" >> ~/versions.txt
Write-Output "emsdk portable jre = $versionJre" >> ~/versions.txt
