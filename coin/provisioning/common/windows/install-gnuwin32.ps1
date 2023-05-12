# Copyright (C) 2019 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only
. "$PSScriptRoot\helpers.ps1"

# This script will install gnuwin32

$prog = "gnuwin32"
$zipPackage = "$prog.zip"
$temp = "$env:tmp"
$internalUrl = "http://ci-files01-hki.ci.qt.io/input/windows/$prog/$zipPackage"
$externalUrl = "http://download.qt.io/development_releases/$prog/$zipPackage"
Download $externalUrl $internalUrl "$temp\$zipPackage"
Verify-Checksum "$temp\$zipPackage" "d7a34a385ccde2374b8a2ca3369e5b8a1452c5a5"
Extract-7Zip "$temp\$zipPackage" C:\Utils

Write-Output "$prog qt5 commit sha = 98c4f1bbebfb3cc6d8e031d36fd1da3c19e634fb" >> ~\versions.txt
Prepend-Path "C:\Utils\gnuwin32\bin"
