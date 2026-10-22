# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# vcpkg only prints the paths of the failed build step logs, which are gone once the CI VM is
# discarded. Print their contents, listed in buildtrees\<port>\error-logs-<triplet>.txt,
# so the CI log shows what failed.
function Write-VcpkgErrorLogs
{
    Get-ChildItem -Path "$env:VCPKG_ROOT\buildtrees\*\error-logs-*.txt" -ErrorAction SilentlyContinue | ForEach-Object {
        # Configure failures also list these, but they are large and the error is in the -out/-err logs.
        Get-Content -Path $_.FullName | Where-Object {
            $_ -and (Test-Path -Path $_ -PathType Leaf) -and $_ -notmatch '-(CMakeCache\.txt|CMakeConfigureLog\.yaml)\.log$'
        } | ForEach-Object {
            Write-Host "===== Contents of $_ ====="
            Get-Content -Path $_ -Raw | Write-Host
        }
    }
}
