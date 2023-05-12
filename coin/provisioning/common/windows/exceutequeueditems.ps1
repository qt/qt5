# Copyright (C) 2018 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
. "$PSScriptRoot\helpers.ps1"

Start-Process -NoNewWindow -FilePath "C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\ngen.exe" -ArgumentList ExecuteQueuedItems -Wait

if( (is64bitWinHost) -eq 1 ) {
   Start-Process -NoNewWindow -FilePath "C:\WINDOWS\Microsoft.NET\Framework64\v4.0.30319\ngen.exe" -ArgumentList ExecuteQueuedItems -Wait
}
