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

. "$PSScriptRoot\helpers.ps1"

# This script will install emscripten needed by WebAssembly

$version = "2.0.14"
$versionTag="fc5562126762ab26c4757147a3b4c24e85a7289e"
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

Write-Output "emsdk = $version" >> ~/versions.txt
Write-Output "emsdk NodeJs = $versionNode" >> ~/versions.txt
Write-Output "emsdk WinPython 64bit = $versionWinPython" >> ~/versions.txt
Write-Output "emsdk portable jre = $versionJre" >> ~/versions.txt
