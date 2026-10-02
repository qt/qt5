# Copyright (C) 2025 The Qt Company Ltd
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\..\common\windows\helpers.ps1"

# This script installs/updates .NET for QtBridges

$vs2022 = [System.IO.File]::Exists("C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat")

if($vs2022) {
    Start-Process -FilePath "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe" -ArgumentList 'modify --installPath "C:\Program Files\Microsoft Visual Studio\2022\Professional" --add Microsoft.VisualStudio.Workload.ManagedDesktop --quiet' -Wait
    Start-Process -FilePath "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe" -ArgumentList 'modify --installPath "C:\Program Files\Microsoft Visual Studio\2022\Professional" --add Microsoft.VisualStudio.Workload.NativeDesktop --quiet' -Wait
}
else {
    # If there is a dotnet not found error: install the latest version in VS installer
    Write-Host ".NET runtime version:"
    dotnet --list-runtimes
    Write-Host ".NET SDK version:"
    dotnet --list-sdks
}
