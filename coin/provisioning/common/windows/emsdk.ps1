# Copyright (C) 2023 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\helpers.ps1"

# This script will install emscripten needed by WebAssembly

$version = "4.0.7"
$zipVersion = $version -replace '\.', "_"
$temp = "$env:tmp"
$cacheUrl = "https://ci-files01-hki.ci.qt.io/input/emsdk/emsdk_windows_${zipVersion}.zip"
$sha = "d433b8353df4a75ba035fc618f520790b4fb7ee2"

# Python used for '.\emsdk install'
$pythonPath = [System.Environment]::GetEnvironmentVariable("PYTHON3_PATH", "Machine")
Prepend-Path $pythonPath

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
    Write-Host "Can't find cached emsdk or another error occurred. Cloning it"
    Write-Host "Error details: $_"

    C:\PROGRA~1\Git\bin\git clone https://github.com/emscripten-core/emsdk.git
    cd $installLocationEmsdk

    try {
        .\emsdk install $version
        .\emsdk activate $version
    } catch {
        throw "emsdk installation failed: $_"
    }
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
