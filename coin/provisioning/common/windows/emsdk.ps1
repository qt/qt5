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


# Make sure python is in the path
Prepend-Path "C:\Python27"

cd "C:\\Utils"
C:\PROGRA~1\Git\bin\git clone https://github.com/emscripten-core/emsdk.git
$installLocationEmsdk = "C:\\Utils\\emsdk"
cd $installLocationEmsdk
.\emsdk install $version
.\emsdk activate $version

$versionWinPython = $($Env:EMSDK_PYTHON -split ('python\\') -split ('_64bit'))[1]
$versionNode = $($Env:EMSDK_NODE -split ('node\\') -split ('_64bit'))[1]
$versionJre = $($Env:EMSDK_JAVA_HOME -split ('java\\') -split ('_64bit'))[1]

# Set these environment variables permanently.
# Note! Using 'emsdk_env.bat --permanent' doesn't set these permanently
Set-EnvironmentVariable "EMSDK" "$env:EMSDK"
Set-EnvironmentVariable "EM_CONFIG" "$env:EM_CONFIG"
Set-EnvironmentVariable "EMSDK_NODE" "$env:EMSDK_NODE"
Set-EnvironmentVariable "EMSDK_PYTHON" "$env:EMSDK_PYTHON"
# In this case JAVA_HOME is the one emsdk install/activate set.
# We need to use EMSDK_JAVA_HOME so that we don't override JAVA_HOME which comes from install-jdk.ps1
Set-EnvironmentVariable "EMSDK_JAVA_HOME" "$env:JAVA_HOME"
Set-EnvironmentVariable "EMSDK_PATH" "$installLocationEmsdk;$installLocationEmsdk\node\${versionNode}_64bit\bin;$installLocationEmsdk\upstream\emscripten;$PATH"
Add-Path "$env:EMSDK_PATH"

Write-Output "emsdk = $version" >> ~/versions.txt
Write-Output "emsdk NodeJs = $versionNode" >> ~/versions.txt
Write-Output "emsdk WinPython 64bit = $versionWinPython" >> ~/versions.txt
Write-Output "emsdk portable jre = $versionJre" >> ~/versions.txt
