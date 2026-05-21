# Copyright (C) 2026 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only WITH Qt-GPL-exception-1.0
#
# Usage: .\qt_run_all.ps1 [directory]
# Script to run all provisioning scripts in the current directory in alphabetical order
# for the purpose of manually provisioning a freshly installed Windows system
#
# Caution:
# - Don't copy this to or call it from a platform provisioning directory
# - It's not guaranteed that scripts are run in the exact same order as during COIN provisioning

param(
    [string]$Dir = "."
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Resolve to absolute path
$Dir = Resolve-Path $Dir -ErrorAction SilentlyContinue
if (-not $Dir) {
    Write-Error "Error: directory not found or not accessible."
    exit 1
}

Write-Host "Running .ps1 files in: $Dir"

Get-ChildItem -Path $Dir -MaxDepth 0 -Filter "*.ps1" |
    Where-Object { $_.FullName -ne $PSCommandPath } |
    Sort-Object Name |
    ForEach-Object {
        Write-Host "--- Running: $($_.FullName)"
        & $_.FullName
        Write-Host "------ Done: $($_.FullName) (exit code: $LASTEXITCODE)"
    }

Write-Host "Provisioning done."
