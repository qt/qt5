############################################################################
##
## Copyright (C) 2023 The Qt Company Ltd.
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

$version = "3.1.37"
$zipVersion = $version -replace '\.', "_"
$temp = "$env:tmp"
$cacheUrl = "https://ci-files01-hki.ci.qt.io/input/emsdk/emsdk_windows_${zipVersion}.zip"
$sha = "5e5c0f50a940be09b82bf8256434f4510270e208"

# Make sure python is in the path
Prepend-Path "C:\Python27"

cd "C:\\Utils"
$installLocationEmsdk = "C:\\Utils\\emsdk"
try {
    Write-Host "Fetching from cached location"
    Download $cacheUrl $cacheUrl ${temp}\${zipVersion}.zip
    Verify-Checksum ${temp}\${zipVersion}.zip $sha
    Extract-7Zip ${temp}\${zipVersion}.zip C:\Utils\
    cd $installLocationEmsdk
    .\emsdk activate $version
} catch {
    Write-Host "Can't find cached emsdk. Cloning it"
    C:\PROGRA~1\Git\bin\git clone https://github.com/emscripten-core/emsdk.git
    cd $installLocationEmsdk
    .\emsdk install $version
    .\emsdk activate $version
}

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

# These can be removed when installing emsdk using emsdk.git
Set-Content -Path C:\Utils\emsdk\emsdk_env.bat -Value ":: This file is needed to get support for setting Emscripten environment for Webassembly through qtbase" -Encoding ASCII
Set-Content -Path C:\Utils\emsdk\emsdk_env.bat -Value ":: This file will have environment variables when https://codereview.qt-project.org/c/qt/qt5/+/372122 get merged" -Encoding ASCII
Set-Content -Path C:\Utils\emsdk\emsdk_env.bat -Value "echo nothing to run at this point" -Encoding ASCII

Write-Output "emsdk = $version" >> ~/versions.txt
Write-Output "emsdk NodeJs = $versionNode" >> ~/versions.txt
Write-Output "emsdk WinPython 64bit = $versionWinPython" >> ~/versions.txt
Write-Output "emsdk portable jre = $versionJre" >> ~/versions.txt
