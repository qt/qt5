#############################################################################
##
## Copyright (C) 2022 The Qt Company Ltd.
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
#############################################################################

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
