# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

# This script creates and shares folders so that we can run I/O tests with
# UNC paths, without depending on an SBM server

$readonly='testshare'
$writable='testsharewritable'
$readonlypath="${env:SystemDrive}\${readonly}"
$writablepath="${env:SystemDrive}\${writable}"

Write-Host "******************** Creating folders ${readonlpath} and ${writablepath}"

if ($(Test-Path -Path $readonlypath)) {
    Remove-SmbShare -Name $readonly -Force
    Remove-Item -Path $readonlypath -Force -Recurse
}
if ($(Test-Path -Path $writablepath)) {
    Remove-SmbShare -Name $writable -Force
    Remove-Item -Path $writablepath -Force -Recurse
}

New-Item ${readonlypath} -ItemType Directory
New-Item "${readonlypath}\tmp" -ItemType Directory
New-SmbShare -Name ${readonly} -Path ${readonlypath} -ReadAccess Users
# As expected by tst_networkselftest, exactly 34 bytes
"This is 34 bytes. Do not change..." `
    | Out-File -Encoding ascii -FilePath "${readonlypath}\test.pri" -NoNewline
New-Item "${readonlypath}\readme.txt" -ItemType File

New-Item ${writablepath} -ItemType Directory
New-SmbShare -Name ${writable} -Path ${writablepath} -ChangeAccess Users

Write-Host "******************** File system content"
dir ${env:SystemDrive}
cd "\\${env:COMPUTERNAME}\${readonly}"
dir
cd "\\${env:COMPUTERNAME}\${writable}"
dir
Write-Host "******************** Done Content"
