# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only WITH Qt-GPL-exception-1.0
#
# Script to run all provisioning scripts in the current directory in alphabetical order
# for the purpose of manually provisioning a freshly installed Windows system
#
# Caution:
# - Don't copy this to or call it from a platform provisioning directory
# - It's not guaranteed that scripts are run in the exact same order as during COIN provisioning

[CmdletBinding()]
param(
    [string]$Dir = ".",
    # Stop at the first script that fails. Default: continue and report all
    # failures at the end.
    [switch]$StopOnError,
    [Alias("h")]
    [switch]$Help
)

function Show-Usage {
    @"
Usage: .\qt_run_all.ps1 [options] [-Dir <directory>]

Run all provisioning scripts (*.ps1, *.bat, *.cmd, *.exe) in the given
directory (default: current directory) in alphabetical order, regardless of
extension.

Options:
  -Dir <directory>   Directory to scan for provisioning scripts (default: current directory).
  -StopOnError       Stop at the first script that fails.
                     Default: continue and report all failures at the end.
  -h, -Help          Show this help and exit.

By default this script does NOT stop on errors: every script is attempted and
failures are collected and reported in a summary at the end. The exit code is
non-zero if any script failed.
"@ | Write-Host
}

if ($Help) {
    Show-Usage
    exit 0
}

Set-StrictMode -Version Latest

# Resolve to absolute path
$resolved = Resolve-Path $Dir -ErrorAction SilentlyContinue
if (-not $resolved) {
    Write-Error "Error: directory not found or not accessible."
    exit 1
}
$Dir = $resolved

Write-Host "Running provisioning scripts (*.ps1, *.bat, *.cmd, *.exe) in: $Dir"

$failed = New-Object System.Collections.Generic.List[string]

$extensions = @(".ps1", ".bat", ".cmd", ".exe")
$scripts = Get-ChildItem -Path $Dir -File |
    Where-Object { $extensions -contains $_.Extension.ToLower() -and $_.FullName -ne $PSCommandPath } |
    Sort-Object Name

foreach ($script in $scripts) {
    Write-Host "--- Running: $($script.FullName)"
    $global:LASTEXITCODE = 0
    try {
        & $script.FullName
    } catch {
        Write-Host "Error: $($_.Exception.Message)"
        if ($global:LASTEXITCODE -eq 0) { $global:LASTEXITCODE = 1 }
    }
    $rc = $global:LASTEXITCODE
    if ($rc -eq 0) {
        Write-Host "------ Done: $($script.FullName) (exit code: 0)"
    } else {
        Write-Host "------ FAILED: $($script.FullName) (exit code: $rc)"
        $failed.Add($script.FullName)
        if ($StopOnError) {
            Write-Host "Stopping on first error (-StopOnError)."
            exit $rc
        }
    }
}

if ($failed.Count -gt 0) {
    Write-Host ""
    Write-Host "Provisioning completed with $($failed.Count) failed script(s):"
    foreach ($f in $failed) { Write-Host "  $f" }
    exit 1
}

Write-Host "Provisioning done."
