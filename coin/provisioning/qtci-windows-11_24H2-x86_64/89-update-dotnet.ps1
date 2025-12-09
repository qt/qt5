# Copyright (C) 2025 The Qt Company Ltd
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

. "$PSScriptRoot\..\common\windows\helpers.ps1"

Start-Process -FilePath "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe" -ArgumentList 'modify --installPath "C:\Program Files\Microsoft Visual Studio\2022\Professional" --add Microsoft.VisualStudio.Workload.ManagedDesktop --quiet' -Wait
Start-Process -FilePath "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe" -ArgumentList 'modify --installPath "C:\Program Files\Microsoft Visual Studio\2022\Professional" --add Microsoft.VisualStudio.Workload.NativeDesktop --quiet' -Wait
